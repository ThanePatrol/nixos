local M = {}

function M.is_cloudtop() return os.getenv("CORP_WORK_ENV") == "true" end

return M
