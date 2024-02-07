vim.lsp.handlers["textDocument/hover"] = function(err, result)
    if err then
        print(err)
        return
    end

    if not result or not result.contents or #result.contents == 0 then
        print("Empty hover resopnse");
        return
    end

    local chunks = {}
    for _, content in pairs(result.contents) do
        if type(content) == 'string' and content ~= '' then
            table.insert(chunks, content)
        elseif type(content) == 'table' and content.value ~= '' then
            table.insert(chunks, content.value)
        end
    end

    if #chunks == 0 then
        print("Empty hover resopnse");
        return
    end

    vim.g.quickPreviewToShowText = vim.fn.join(chunks, "\n");


    vim.api.nvim_command('call QuickPreview(g:quickPreviewToShowText)')
    -- vim.api.nvim_command('call CreatePreviewCloseAugroup()')
end
