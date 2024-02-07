if FuzzyContentSearch then return end
FuzzyContentSearch = {}

local searchBuffer = nil

local latestContentQuery = nil
local latestFilepathQuery = nil
local searchingScopeFilePath = '/tmp/fuzzy-content-searching-scope.txt'
local searchingContentFilePath = '/tmp/fuzzy-content-searching-content.txt'
local maxDisplayedResultCount = 100
local latestScopeFiles = {}
local latestSearchResult = {}
local latestSearchResultFilePath = '/tmp/fuzzy-content-latest-result.txt'

---@param match string
local function extractMatchParameters(match)
    local items = vim.fn.split(match, ':')
    local matchText = vim.fn.join({ unpack(items, 3, #items) }, ':')

    local line = tonumber(items[2])
    local filePath = latestScopeFiles[tonumber(items[1])]
    if line == nil or filePath == nil then
        return nil
    end
    return {
        filePath = filePath,
        line = line,
        matchText = matchText,
    }
end

---@param match string
local function formatMatch(match)
    local params = extractMatchParameters(match)
    if params == nil then
        return nil
    end
    local textTotalLength = 30
    local matchTextTruncated = string.sub(params.matchText, 1, textTotalLength)
    local text = matchTextTruncated ..
        string.rep(' ', math.max(0, textTotalLength - #matchTextTruncated))

    return text .. '\t' .. params.filePath .. ':' .. params.line
end

local function search()
    local start = vim.fn.reltime()
    local contentQuery = vim.fn.getbufoneline(searchBuffer, 1)
    local filepathQuery = vim.fn.getbufoneline(searchBuffer, 2)

    local bufinfo = vim.fn.getbufinfo(searchBuffer)[1]
    local lineCount = 1
    if bufinfo then
        lineCount = bufinfo['linecount'] or lineCount
    end

    if lineCount == 1 then
        vim.fn.setbufline(searchBuffer, 2, '')
    end

    if contentQuery == latestContentQuery and filepathQuery == latestFilepathQuery then
        return
    end

    local finish = vim.fn.reltime(start)
    local finish2 = vim.fn.reltime(start)
    if filepathQuery ~= latestFilepathQuery then
        vim.fn.system(
            'fd --type f | ' ..
            'fzf --filter="' .. filepathQuery .. '" ' ..
            '> ' .. searchingScopeFilePath
        );
        local reply = vim.fn.system('cat ' .. searchingScopeFilePath)
        latestScopeFiles = vim.fn.split(reply, '\n')
        --vim.fn.system(
        --    'xargs --max-procs=2 --arg-file="' .. searchingScopeFilePath .. '" -d "\n" ' ..
        --    [[awk 'BEGIN{FNUM=1}ENDFILE{FNUM++}length{print FNUM":"FNR":"$0}']] ..
        --    -- [[awk '{print $0}']] ..
        --    -- 'rg "" --heading --line-number ' ..
        --    '> ' .. searchingContentFilePath
        --)
        finish = vim.fn.reltime(start)
        vim.fn.system(
            'cat ' .. searchingScopeFilePath ..  ' | ' ..
            [[xargs -d '\n' rg "" --no-heading --line-number]] ..
            '> ' .. searchingContentFilePath
        )
    end

    vim.fn.setbufline(searchBuffer, 3, '')
    vim.fn.setbufline(searchBuffer, 4, '')
    -- delete file content
    vim.fn.deletebufline(searchBuffer, 5, '$')

    vim.fn.system(
        'cat ' .. searchingContentFilePath .. ' | ' ..
        'fzf --algo=v2 --filter="' .. contentQuery .. '"' ..
        ' > ' .. latestSearchResultFilePath
    )

    local reply = vim.fn.system('cat ' .. latestSearchResultFilePath .. ' | head -n 500')
    local lines = vim.fn.split(reply, '\n')
    latestSearchResult = lines
    local linesToShow = { unpack(lines, 1, math.min(#lines, maxDisplayedResultCount)) }

    local linesToShowFormatted = linesToShow
    --for _,line in pairs(linesToShow) do
    --    local formattedLine = formatMatch(line)
    --    if formattedLine ~= nil then
    --        table.insert(linesToShowFormatted, formattedLine)
    --    end
    --end

    vim.fn.appendbufline(searchBuffer, 4, linesToShowFormatted);

    latestFilepathQuery = filepathQuery
    latestContentQuery = contentQuery
    finish2 = vim.fn.reltime(start)


    local statusLine = vim.fn.reltimestr(finish) .. '/' .. vim.fn.reltimestr(finish2) .. (latestContentQuery or 'none') .. 'files ' .. #latestScopeFiles .. ', matches ' .. #lines
    vim.fn.setbufline(searchBuffer, 3, statusLine)

end


FuzzyContentSearch.openSearch = function(reset)
    local shouldReset = reset
    if searchBuffer == nil then
        -- create buffer
        vim.api.nvim_command('enew')
        searchBuffer = vim.fn.bufnr()
        vim.api.nvim_buf_set_name(searchBuffer, 'Search Content')
        vim.api.nvim_command(
            'autocmd ' ..
            'TextChangedI,TextChanged,TextChangedP ' ..
            '<buffer=' .. searchBuffer .. '> lua FuzzyContentSearch.throttling()'
        )
        vim.api.nvim_buf_set_keymap(
            searchBuffer,
            'n',
            '<enter>',
            '<cmd>lua FuzzyContentSearch.copyResultToQuickFix()<CR>',
            {}
        )
        vim.api.nvim_command('setl nobuflisted noswapfile buftype=nofile')
        shouldReset = 1
    end

    vim.api.nvim_command('b ' .. searchBuffer)

    if shouldReset then
        vim.fn.deletebufline(searchBuffer, 2, '$')
        vim.fn.setbufline(searchBuffer, 1, '')
        vim.fn.setbufline(searchBuffer, 2, '')
        vim.api.nvim_command('startinsert')
        search();
    end
end


local throttlingTimer = 0
local throttlingMs = 200
FuzzyContentSearch.throttling = function()
    vim.fn.timer_stop(throttlingTimer)
    throttlingTimer = vim.fn.timer_start(throttlingMs, search)
end


FuzzyContentSearch.copyResultToQuickFix = function()
    local locationlist = {}
    for _, line in ipairs(latestSearchResult) do
        local components = vim.fn.split(line, ":")
        local match = table.concat(
            vim.list_slice(
                vim.fn.split(line, ":"),
                3
            ),
            ":"
        )
        local bufnumber = vim.fn.bufnr(components[1], 1)
        table.insert(locationlist, {
            ['bufnr'] = bufnumber,
            ['text'] = match,
            ['lnum'] = components[2],
            ['valid'] = 1,
        })
    end
    vim.fn.setloclist(0, locationlist)
    print("Copied " .. #locationlist .. " items to the Location List")
end



-- vim.api.nvim_set_keymap('n', '<space>r', ':lua FuzzyContentSearch.openSearch(false)<enter>', {})
-- vim.api.nvim_set_keymap('n', '<space>R', ':lua FuzzyContentSearch.openSearch(true)<enter>', {})
