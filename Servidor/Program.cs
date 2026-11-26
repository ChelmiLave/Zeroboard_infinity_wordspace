using System.ComponentModel.DataAnnotations;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Threading.RateLimiting;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);
builder.Logging.ClearProviders();
builder.Logging.AddConsole();
var dataDir = Path.GetFullPath(builder.Configuration["DataDirectory"] ?? "App_Data");
Directory.CreateDirectory(dataDir);
builder.Services.AddDbContext<BoardDb>(o => o.UseSqlite($"Data Source={Path.Combine(dataDir, "zeroboard.db")};Foreign Keys=True"));
builder.Services.AddSingleton<IPasswordHasher<Account>, PasswordHasher<Account>>();
builder.Services.AddRateLimiter(o => {
    o.RejectionStatusCode = 429;
    o.AddPolicy("auth", c => RateLimitPartition.GetFixedWindowLimiter(c.Connection.RemoteIpAddress?.ToString() ?? "unknown", _ => new FixedWindowRateLimiterOptions { PermitLimit = 12, Window = TimeSpan.FromMinutes(1), QueueLimit = 0 }));
});
builder.WebHost.ConfigureKestrel(o => o.Limits.MaxRequestBodySize = 24 * 1024 * 1024);
var app = builder.Build();
app.UseExceptionHandler(handler => handler.Run(async c => { c.Response.StatusCode = 500; await c.Response.WriteAsJsonAsync(new { message = "No fue posible completar la operación. Intenta de nuevo." }); }));
app.Use(async (ctx, next) => {
    ctx.Response.Headers["X-Content-Type-Options"] = "nosniff";
    ctx.Response.Headers["Cache-Control"] = "no-store";
    if (!app.Environment.IsDevelopment() && !ctx.Request.IsHttps) { ctx.Response.StatusCode = 400; await ctx.Response.WriteAsJsonAsync(new { message = "Se requiere HTTPS." }); return; }
    await next();
});
app.UseRateLimiter();
using (var scope = app.Services.CreateScope()) { var db = scope.ServiceProvider.GetRequiredService<BoardDb>(); db.Database.EnsureCreated(); db.Database.ExecuteSqlRaw("PRAGMA journal_mode=WAL;"); }

app.MapGet("/health", () => new { status = "ok", version = "2.0.0" });
app.MapPost("/auth/register", async (Credentials input, BoardDb db, IPasswordHasher<Account> hasher) => {
    var email = Normalize(input.Email);
    if (!new EmailAddressAttribute().IsValid(email) || email.Length > 254 || !ValidPassword(input.Password)) return Error(400, "Introduce un correo válido y una contraseña de 12 a 128 caracteres.");
    var user = new Account { Id = Guid.NewGuid().ToString(), Email = email };
    user.PasswordHash = hasher.HashPassword(user, input.Password);
    var recovery = Secret(); user.RecoveryHash = Hash(recovery);
    db.Accounts.Add(user);
    try { await db.SaveChangesAsync(); } catch (DbUpdateException) { return Error(409, "No fue posible registrar ese correo. Inicia sesión o usa otro."); }
    return Results.Ok(await Issue(user, db, recovery));
}).RequireRateLimiting("auth");
app.MapPost("/auth/login", async (Credentials input, BoardDb db, IPasswordHasher<Account> hasher) => {
    var email = Normalize(input.Email);
    var user = await db.Accounts.SingleOrDefaultAsync(u => u.Email == email);
    if (user is null || string.IsNullOrEmpty(input.Password) || input.Password.Length > 128 || hasher.VerifyHashedPassword(user, user.PasswordHash, input.Password) == PasswordVerificationResult.Failed) return Error(401, "Correo o contraseña incorrectos.");
    return Results.Ok(await Issue(user, db));
}).RequireRateLimiting("auth");
app.MapPost("/auth/recover", async (Recovery input, BoardDb db, IPasswordHasher<Account> hasher) => {
    if (!ValidPassword(input.Password)) return Error(400, "La contraseña debe tener entre 12 y 128 caracteres.");
    var email = Normalize(input.Email);
    var user = await db.Accounts.SingleOrDefaultAsync(u => u.Email == email);
    if (user is null || string.IsNullOrEmpty(input.Code) || input.Code.Length > 100 || !CryptographicOperations.FixedTimeEquals(Encoding.UTF8.GetBytes(user.RecoveryHash), Encoding.UTF8.GetBytes(Hash(input.Code)))) return Error(401, "Correo o código de recuperación incorrectos.");
    user.PasswordHash = hasher.HashPassword(user, input.Password);
    var code = Secret(); user.RecoveryHash = Hash(code);
    await db.Sessions.Where(s => s.AccountId == user.Id).ExecuteDeleteAsync();
    await db.SaveChangesAsync();
    return Results.Ok(await Issue(user, db, code));
}).RequireRateLimiting("auth");

var api = app.MapGroup("/api");
api.AddEndpointFilter(async (context, next) => {
    var db = context.HttpContext.RequestServices.GetRequiredService<BoardDb>();
    var token = context.HttpContext.Request.Headers.Authorization.ToString();
    if (!token.StartsWith("Bearer ") || token.Length > 200) return Error(401, "Inicia sesión para continuar.");
    var hash = Hash(token[7..]);
    var session = await db.Sessions.AsNoTracking().SingleOrDefaultAsync(s => s.TokenHash == hash);
    if (session is null || session.ExpiresAt <= DateTimeOffset.UtcNow.ToUnixTimeSeconds()) return Error(401, "La sesión expiró. Inicia sesión de nuevo.");
    context.HttpContext.Items["user"] = session.AccountId;
    context.HttpContext.Items["token"] = hash;
    return await next(context);
});
api.MapPost("/logout", async (HttpContext c, BoardDb db) => { await db.Sessions.Where(s => s.TokenHash == (string)c.Items["token"]!).ExecuteDeleteAsync(); return Results.NoContent(); });
api.MapGet("/projects", async (HttpContext c, BoardDb db) => { var owner = UserId(c); return Results.Ok(await db.Projects.AsNoTracking().Where(p => p.AccountId == owner).OrderByDescending(p => p.ModifiedAt).Select(p => new { p.Id, p.Title, p.Revision, p.Deleted, p.ModifiedAt }).ToListAsync()); });
api.MapGet("/projects/{id}", async (string id, HttpContext c, BoardDb db) => {
    var owner = UserId(c);
    var p = await db.Projects.AsNoTracking().SingleOrDefaultAsync(p => p.Id == id && p.AccountId == owner);
    return p is null ? Results.NotFound() : Results.Ok(p);
});
api.MapPut("/projects/{id}", async (string id, ProjectInput input, HttpContext c, BoardDb db) => {
    if (!Guid.TryParse(id, out _) || string.IsNullOrWhiteSpace(input.Title) || input.Title.Length > 120 || input.Revision < 0 || input.Document is null || input.Document.Length > 20 * 1024 * 1024) return Error(400, "Proyecto inválido o demasiado grande (máximo 20 MB).");
    try { using var doc = JsonDocument.Parse(input.Document); if (!ProjectValidator.Valid(doc.RootElement, id)) return Error(400, "Estructura de proyecto inválida."); } catch (Exception e) when (e is JsonException or KeyNotFoundException or InvalidOperationException or FormatException) { return Error(400, "El documento no es un proyecto ZeroBoard válido."); }
    var owner = UserId(c);
    var p = await db.Projects.SingleOrDefaultAsync(p => p.Id == id && p.AccountId == owner);
    if (p is null) {
        if (input.Revision != 0) return Error(409, "La copia del servidor cambió.");
        p = new BoardProject { Id = id, AccountId = owner }; db.Projects.Add(p);
    } else if (p.Revision != input.Revision) return Error(409, "Hay cambios en otro dispositivo. Conserva ambas versiones.");
    p.Title = input.Title.Trim(); p.Document = input.Document; p.Deleted = input.Deleted; p.Revision++; p.ModifiedAt = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
    try { await db.SaveChangesAsync(); } catch (DbUpdateException) { return Error(409, "El proyecto cambió durante el guardado. Conserva ambas versiones."); }
    return Results.Ok(new { p.Id, p.Revision, p.ModifiedAt });
});
api.MapDelete("/account", async (HttpContext c, BoardDb db) => { var owner = UserId(c); await db.Accounts.Where(u => u.Id == owner).ExecuteDeleteAsync(); return Results.NoContent(); });
app.Run();

static string Normalize(string? s) => (s ?? "").Trim().ToLowerInvariant();
static bool ValidPassword(string? s) => s is not null && s.Length is >= 12 and <= 128;
static string Secret() => Convert.ToHexString(RandomNumberGenerator.GetBytes(32)).ToLowerInvariant();
static string Hash(string s) => Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(s)));
static string UserId(HttpContext c) => (string)c.Items["user"]!;
static IResult Error(int status, string message) => Results.Json(new { message }, statusCode: status);
static async Task<object> Issue(Account u, BoardDb db, string? recoveryCode = null) {
    var now = DateTimeOffset.UtcNow.ToUnixTimeSeconds();
    await db.Sessions.Where(s => s.ExpiresAt < now).ExecuteDeleteAsync();
    var token = Secret(); var expires = DateTimeOffset.UtcNow.AddDays(30).ToUnixTimeSeconds();
    db.Sessions.Add(new LoginSession { TokenHash = Hash(token), AccountId = u.Id, ExpiresAt = expires });
    await db.SaveChangesAsync(); return new { accessToken = token, accountId = u.Id, email = u.Email, expiresAt = expires, recoveryCode };
}
record Credentials(string Email, string Password);
record Recovery(string Email, string Password, string Code);
record ProjectInput(string Title, string Document, int Revision, bool Deleted);
class Account {
    public string Id { get; set; } = "";
    public string Email { get; set; } = "";
    public string PasswordHash { get; set; } = "";
    public string RecoveryHash { get; set; } = "";
}
class LoginSession {
    [Key] public string TokenHash { get; set; } = "";
    public string AccountId { get; set; } = "";
    public long ExpiresAt { get; set; }
}
class BoardProject {
    public string Id { get; set; } = "";
    public string AccountId { get; set; } = "";
    public string Title { get; set; } = "";
    public string Document { get; set; } = "";
    public int Revision { get; set; }
    public bool Deleted { get; set; }
    public long ModifiedAt { get; set; }
}
class BoardDb(DbContextOptions<BoardDb> options) : DbContext(options) {
    public DbSet<Account> Accounts => Set<Account>();
    public DbSet<LoginSession> Sessions => Set<LoginSession>();
    public DbSet<BoardProject> Projects => Set<BoardProject>();
    protected override void OnModelCreating(ModelBuilder b) {
        b.Entity<Account>().HasIndex(u => u.Email).IsUnique();
        b.Entity<BoardProject>().HasKey(p => new { p.AccountId, p.Id });
        b.Entity<BoardProject>().Property(p => p.Revision).IsConcurrencyToken();
        b.Entity<BoardProject>().HasOne<Account>().WithMany().HasForeignKey(p => p.AccountId).OnDelete(DeleteBehavior.Cascade);
        b.Entity<LoginSession>().HasOne<Account>().WithMany().HasForeignKey(p => p.AccountId).OnDelete(DeleteBehavior.Cascade);
    }
}
