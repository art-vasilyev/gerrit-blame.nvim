local M = {}

M.config = {
    gerrit_hosts = { "review.opendev.org" },
    default_host = "review.opendev.org",
}

local function get_sha_from_line(line)
    return line:match("^([0-9a-f]+)")
end

local function get_change_id(sha)
    local result = vim.system({ "git", "log", "-n", "1", "--pretty=format:%B", sha }, { text = true }):wait()
    if result.code ~= 0 then return nil end
    return result.stdout:match("Change%-Id:%s*(I[0-9a-fA-F]+)")
end

local function get_gerrit_host()
    local result = vim.system({ "git", "remote", "get-url", "origin" }, { text = true }):wait()
    if result.code ~= 0 then
        return M.config.default_host
    end

    local url = vim.trim(result.stdout)
    local host = url:match("^[^@]+@([^:]+):") or url:match("^https?://([^/]+)")
    if not host then
        return M.config.default_host
    end

    for _, allowed_host in ipairs(M.config.gerrit_hosts) do
        if host == allowed_host then
            return host
        end
    end

    return M.config.default_host
end

local function open_url(url)
    local opener
    if vim.fn.has("mac") == 1 then
        opener = "open"
    elseif vim.fn.has("win32") == 1 then
        opener = "start"
    else
        opener = "xdg-open"
    end

    vim.fn.jobstart({ opener, url }, { detach = true })
end

function M.open_gerrit_review()
    local line = vim.api.nvim_get_current_line()
    local sha = get_sha_from_line(line)
    if not sha then
        vim.notify("No commit SHA found on this line", vim.log.levels.WARN)
        return
    end

    local change_id = get_change_id(sha)
    if not change_id then
        vim.notify("No Change-Id found in commit " .. sha, vim.log.levels.WARN)
        return
    end

    local host = get_gerrit_host()

    local url = string.format("https://%s/q/%s", host, change_id)
    vim.notify("Opening Gerrit review: " .. url, vim.log.levels.INFO)
    open_url(url)
end

function M.setup(opts)
    M.config = vim.tbl_deep_extend("force", M.config, opts or {})

    vim.api.nvim_create_autocmd("FileType", {
        pattern = "fugitiveblame",
        callback = function()
            vim.keymap.set("n", "gR", M.open_gerrit_review, {
                buffer = true,
                desc = "Open Gerrit review for Change-Id",
            })
        end,
    })
end

return M
