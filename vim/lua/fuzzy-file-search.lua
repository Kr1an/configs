if FuzzyFileSearch then return end
FuzzyFileSearch = {}

local searchBuffer = nil

local latestSearchQuery = nil
local searchingScopeFilePath = '/tmp/fuzzy-file-searching-scope.txt'
local maxDisplayedResultCount = 100
local latestSearchResult = {}

local function search()
    local query = vim.fn.getbufoneline(searchBuffer, 1)
    local bufinfo = vim.fn.getbufinfo(searchBuffer)[1]
    local lineCount = 1
    if bufinfo then
        lineCount = bufinfo['linecount'] or lineCount
    end

    if query == latestSearchQuery then
        -- nothing changed in search, skipping
        return
    end

    if query == '' then
        -- populate fd list
        vim.fn.system('fd --type f > ' .. searchingScopeFilePath);
    end

    latestSearchQuery = query

    -- delete file content
    vim.fn.deletebufline(searchBuffer, 3, '$')

    local reply = vim.fn.system(
        'cat ' .. searchingScopeFilePath .. ' | ' ..
        'fzf --filter="' .. query .. '"'
    )
    local lines = vim.fn.split(reply, '\n')

    local linesToShow = { unpack(lines, 1, math.min(#lines, maxDisplayedResultCount)) }

    vim.fn.setbufline(searchBuffer, 2, 'lines ' .. #lines .. '')
    vim.fn.setbufline(searchBuffer, 3, '')
    vim.fn.appendbufline(searchBuffer, 3, linesToShow);

    latestSearchResult = lines
end


FuzzyFileSearch.copyResultToQuickFix = function()
    local locationlist = {}
    for _, line in ipairs(latestSearchResult) do
        local bufnumber = vim.fn.bufnr(line, 1)
        table.insert(locationlist, {
            ['bufnr'] = bufnumber,
            ['valid'] = 1,
        })
    end
    vim.fn.setloclist(0, locationlist)
    print('copied to location list')
end


FuzzyFileSearch.openSearch = function(reset)

    if searchBuffer == nil then
        -- create buffer
        vim.api.nvim_command('enew')
        searchBuffer = vim.fn.bufnr()
        vim.api.nvim_buf_set_name(searchBuffer, 'Search Files')
        vim.api.nvim_command(
            'autocmd ' ..
            'TextChangedI,TextChanged,TextChangedP ' ..
            '<buffer=' .. searchBuffer .. '> lua FuzzyFileSearch.throttling()'
        )
        vim.api.nvim_buf_set_keymap(
            searchBuffer,
            'n',
            '<enter>',
            '<cmd>lua FuzzyFileSearch.copyResultToQuickFix()<CR>',
            {}
        )
        vim.api.nvim_command('setl nobuflisted noswapfile buftype=nofile')
        reset = 1
    end


    vim.api.nvim_command('b ' .. searchBuffer)

    if reset then
        vim.fn.setbufline(searchBuffer, 1, '')
        vim.api.nvim_command('startinsert')
        search();
    end

end


local throttlingTimer = 0
local throttlingMs = 20
FuzzyFileSearch.throttling = function()
    vim.fn.timer_stop(throttlingTimer)
    throttlingTimer = vim.fn.timer_start(throttlingMs, search)
end

--vim.api.nvim_set_keymap('n', '<space>f', ':lua FuzzyFileSearch.openSearch(false)<enter>', {})
--vim.api.nvim_set_keymap('n', '<space>F', ':lua FuzzyFileSearch.openSearch(true)<enter>', {})
