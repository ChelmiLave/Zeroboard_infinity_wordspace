using System.Text.Json;

static class ProjectValidator
{
    public static bool Valid(JsonElement root, string id)
    {
        if (root.GetProperty("version").GetInt32() != 2 || root.GetProperty("id").GetString() != id ||
            root.GetProperty("type").GetString() is not ("presentation" or "document" or "whiteboard") ||
            string.IsNullOrWhiteSpace(root.GetProperty("title").GetString()) ||
            root.GetProperty("title").GetString()!.Length > 120 || !root.GetProperty("modified").TryGetInt64(out _)) return false;
        var pages = root.GetProperty("pages");
        if (pages.ValueKind != JsonValueKind.Array || pages.GetArrayLength() is < 1 or > 200) return false;
        var ids = new HashSet<string>();
        foreach (var page in pages.EnumerateArray())
        {
            if (!UniqueId(page, ids) || !Number(page, "width", 100, 10000) || !Number(page, "height", 100, 10000)) return false;
            var elements = page.GetProperty("elements");
            if (elements.ValueKind != JsonValueKind.Array || elements.GetArrayLength() > 2000) return false;
            foreach (var e in elements.EnumerateArray())
            {
                if (!UniqueId(e, ids) || e.GetProperty("kind").GetString() is not ("rectangle" or "ellipse" or "triangle" or "text" or "note" or "pen" or "image" or "line") ||
                    !Number(e, "width", 8, 10000) || !Number(e, "height", 8, 10000) || !Number(e, "x", -100000, 100000) || !Number(e, "y", -100000, 100000)) return false;
            }
        }
        return true;
    }
    static bool UniqueId(JsonElement e, HashSet<string> seen) => e.TryGetProperty("id", out var id) &&
        id.ValueKind == JsonValueKind.String && Guid.TryParse(id.GetString(), out _) && seen.Add(id.GetString()!);
    static bool Number(JsonElement e, string key, double low, double high) => e.TryGetProperty(key, out var p) &&
        p.ValueKind == JsonValueKind.Number && p.TryGetDouble(out var n) && double.IsFinite(n) && n >= low && n <= high;
}
