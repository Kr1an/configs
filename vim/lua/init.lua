--local cmp = require('cmp')
local lspconfig = require('lspconfig')
local util = require('lspconfig.util')
require('./fuzzy-file-search');
require('./fuzzy-content-search');

vim.lsp.handlers["textDocument/hover"] = function(err, result, ctx, config)
  vim.lsp.handlers.hover(err, result, ctx, {
    zindex = 300,
    border = "single"
  })
end

local on_attach = function(client, bufnr)
    -- highlighting
    if client.server_capabilities and client.server_capabilities.documentHighlightProvider then
        vim.api.nvim_command(
            'autocmd CursorHold  <buffer> lua vim.lsp.buf.document_highlight()'
        )
        vim.api.nvim_command(
            'autocmd CursorHoldI <buffer> lua vim.lsp.buf.document_highlight()'
        )
        vim.api.nvim_command(
            'autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()'
        )
    end

    local opts = {}
     -- goto
     vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
     vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
     vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
     vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
     vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
     vim.api.nvim_buf_set_keymap(bufnr, 'i', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
     vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
     vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
     --vim.api.nvim_buf_set_keymap(bufnr, 'n', 'ne', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
     vim.api.nvim_buf_set_keymap(bufnr, 'n', '!', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
end

local servers = {
    'tsserver',
    'solidity_ls',
    --'jsonls',
    'rust_analyzer',
    'svelte',
    'vimls',
    --'pylsp',
    --'terraform_lsp',
    'terraformls',
    --'pyright'
    'glsl_analyzer',
    --'lua_ls',
}

local pid = vim.fn.getpid()
local omnisharp_bin = "/usr/bin/omnisharp"
lspconfig['omnisharp'].setup {
    settings = {
        enable_editorconfig_support = true,
        enable_roslyn_analyzers     = false,
        enable_import_completion    = true,
    },
    on_attach = on_attach,
    -- root_dir = util.root_pattern('.sln', '.csproj'),
    cmd = { omnisharp_bin, "--languageserver" , "--hostPID", tostring(pid), "--verbose" },
    -- fixes issue with multiple solutions opened simultaniously
    on_new_config = function(new_config, new_root_dir)
    end,
}

--lspconfig['tsserver'].setup {
--    cmd = { '/home/anton/Workspace/test/test-py/node_modules/.bin/typescript-language-server', '--stdio' }
--}


--lspconfig['tsserver'].setup {
--    --cmd = { 'bash', '-c', 'tee /tmp/ts-lsp-stdin | /home/anton/Workspace/test/test-py/node_modules/.bin/tsserver --stdio | tee /tmp/ts-lsp-stdout' },
--    cmd = {
--        'tsserver',
--        '--stdio',
--    },
--    settings = {
--        tsserver = {
--            logDirectory = '/tmp/tslogs'
--        }
--    }
--}



lspconfig['pyright'].setup {
    cmd = { "/home/anton/python_venv/bin/pyright-langserver", "--stdio" },
    on_attach = on_attach,
    root_dir = util.root_pattern('main.py', 'requirements.txt', '__init__.py'),
    settings = {
        python = {
            pythonPath = "/home/anton/python_venv/bin/python",
            analysis = {
                autoImportCompletions = true
            }
        }
    }
}

--local configs = require 'lspconfig.configs'
--if not configs.pyls then
--    configs.pyls = {
--        default_config = {
--            on_attach = on_attach,
--            root_dir = util.root_pattern('main.py', 'requirements.txt', '__init__.py'),
--            --cmd = { "/home/anton/python_venv/bin/jedi-language-server" },
--            cmd = { "/home/anton/python_venv/bin/pylsp" },
--            on_new_config = function(new_config, new_root_dir)
--            end,
--            filetypes = { 'python' },
--        },
--    }
--end
--lspconfig.pyls.setup {}

-- require('lspconfig').yamlls.setup {
--   on_attach = on_attach,
--   settings = {
--     yaml = {
--       schemas = {
--       },
--     },
--   }
-- }

local configs = require('lspconfig.configs')
local lspconfig = require('lspconfig')
local util = require('lspconfig.util')

if not configs.helm_ls then
  configs.helm_ls = {
    default_config = {
      cmd = {"helm_ls", "serve"},
      filetypes = {'helm'},
      root_dir = function(fname)
        return util.root_pattern('Chart.yaml')(fname)
      end,
    },
  }
end

 lspconfig.helm_ls.setup {
   filetypes = {"helm"},
   cmd = {"helm_ls", "serve"},
 }

lspconfig['solc'].setup {
  on_attach = on_attach,
  root_dir = util.root_pattern('README.md', 'package.json', 'node_modules', '.git'),
  -- cmd = {'bash', '-c', 'solc --include-path node_modules --lsp |& tee -a /tmp/solc-lsp-srv-logs'}
  -- flags = {
  --   -- This will be the default in neovim 0.7+
  --   -- debounce_text_changes = 150,
  -- },
}

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    --capabilities = capabilities,
    root_dir = util.root_pattern('README.md', 'package.json', 'node_modules'),
    -- cmd = {'bash', '-c', 'solc --include-path node_modules --lsp |& tee -a /tmp/solc-lsp-srv-logs'}
    -- flags = {
    --   -- This will be the default in neovim 0.7+
    --   -- debounce_text_changes = 150,
    -- },
  }
end





-- helper function to print lua's tables 
function print_table(node)
    local cache, stack, output = {},{},{}
    local depth = 1
    local output_str = "{\n"

    while true do
        local size = 0
        for k,v in pairs(node) do
            size = size + 1
        end

        local cur_index = 1
        for k,v in pairs(node) do
            if (cache[node] == nil) or (cur_index >= cache[node]) then

                if (string.find(output_str,"}",output_str:len())) then
                    output_str = output_str .. ",\n"
                elseif not (string.find(output_str,"\n",output_str:len())) then
                    output_str = output_str .. "\n"
                end

                -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
                table.insert(output,output_str)
                output_str = ""

                local key
                if (type(k) == "number" or type(k) == "boolean") then
                    key = "["..tostring(k).."]"
                else
                    key = "['"..tostring(k).."']"
                end

                if (type(v) == "number" or type(v) == "boolean") then
                    output_str = output_str .. string.rep('\t',depth) .. key .. " = "..tostring(v)
                elseif (type(v) == "table") then
                    output_str = output_str .. string.rep('\t',depth) .. key .. " = {\n"
                    table.insert(stack,node)
                    table.insert(stack,v)
                    cache[node] = cur_index+1
                    break
                else
                    output_str = output_str .. string.rep('\t',depth) .. key .. " = '"..tostring(v).."'"
                end

                if (cur_index == size) then
                    output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
                else
                    output_str = output_str .. ","
                end
            else
                -- close the table
                if (cur_index == size) then
                    output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
                end
            end

            cur_index = cur_index + 1
        end

        if (size == 0) then
            output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
        end

        if (#stack > 0) then
            node = stack[#stack]
            stack[#stack] = nil
            depth = cache[node] == nil and depth + 1 or depth - 1
        else
            break
        end
    end

    -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
    table.insert(output,output_str)
    output_str = table.concat(output)

    print(output_str)
end


--vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
--    print('in handler')
--end

--function start_server()
--    local lsp_id = vim.lsp.start({
--        name = 'pyright',
--        --cmd = { 'bash', '-c', 'tee /tmp/py-lsp-stdin | /home/anton/python_venv/bin/pyright-langserver --stdio | tee /tmp/py-lsp-stdout' },
--        --cmd = {'bash', '-c', 'tee /tmp/pyright-stdin | /home/anton/python_venv/bin/pyright-langserver --stdio | tee /tmp/pyright-stdout'},
--        cmd = { 'bash', '-c', 'tee /tmp/ts-lsp-stdin | typescript-language-server --stdio | tee /tmp/ts-lsp-stdout' },
--        root_dir = vim.fs.dirname(
--            vim.fs.find(
--                --{ 'main.py' },
--                {'index.ts' },
--                { upward = true }
--            )[1]
--        ),
--        --single_file_support = true,
--        --settings = {
--        --    python = {
--        --        pythonPath = "/home/anton/python_venv/bin/python",
--        --        analysis = {
--        --            autoImportCompletions = true,
--        --            autoSearchPaths = true,
--        --            diagnosticMode = "openFilesOnly",
--        --            useLibraryCodeForTypes = true
--        --        }
--        --    }
--        --}
--    })
--    print('server id', lsp_id)
--end
--
--function attash_client()
--    vim.lsp.buf_attach_client(1, 1)
--    print(vim.lsp.buf_is_attached(1, 1))
--end
--
--function codeAction()
--    range = vim.lsp.util.make_range_params()
--    range['range']['end']['character'] = 21
--    vim.lsp.rpc.request(
--        'textDocument/codeAction',
--        {
--            range = range
--        }
--        --{"textDocument":{"uri":"file:///home/anton/Workspace/test/test-py/main.py"},"context":{"diagnostics":[],"triggerKind":1},"range":{"end":{"line":0,"character":6},"start":{"line":0,"character":6}}},"id":8,"jsonrpc":"2.0"}
--
--    )
--end
--
--
--
--

require'lspconfig'.lua_ls.setup {
  on_attach = on_attach,
  on_init = function(client)
    local path = client.workspace_folders[1].name
    if not vim.loop.fs_stat(path..'/.luarc.json') and not vim.loop.fs_stat(path..'/.luarc.jsonc') then
      client.config.settings = vim.tbl_deep_extend('force', client.config.settings, {
        Lua = {
          runtime = {
            -- Tell the language server which version of Lua you're using
            -- (most likely LuaJIT in the case of Neovim)
            version = 'LuaJIT'
          },
          workspace = {
            --checkThirdParty = false,
            library = {
              vim.env.VIMRUNTIME
            }
          }
        }
      })

      client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
    end
    return true
  end
}

