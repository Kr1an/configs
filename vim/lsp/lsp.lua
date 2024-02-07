local tsserverExecutable = '/home/anton/.nvm/versions/node/v19.6.0/lib/node_modules/typescript-language-server/lib/cli.mjs'

function StartTypescriptServer()
    vim.lsp.start({
        name = 'Typescript Server',
        cmd = { 'bash', '-c', 'tee /tmp/ts-lsp-stdin | ' .. tsserverExecutable .. ' --stdio | tee /tmp/ts-lsp-stdout' },
        --cmd = { tsserverExecutable, '--stdio' },
        -- cmd = { 'bash', '-c', 'TSS_LOG=' ..  tsserverExecutable },
        root_dir = vim.fn.getcwd(),
        --cmd_env = {
        --    TSS_LOG = "-level verbose -file /tmp/tsserver.log"
        --}
    })
end

function Test4()
    vim.api.nvim_open_win(
        36,
        false,
        {
            relative = "win",
            win = 1,
            bufpos = {1, 1},
            width = 10,
            height = 5,
            border = 'single'
        }
    )
end
