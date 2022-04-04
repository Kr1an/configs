require('packer').startup(function()
    use 'wbthomason/packer.nvim'
    use 'airblade/vim-gitgutter'
    use 'editorconfig/editorconfig-vim'
    use 'pangloss/vim-javascript'
    use 'tomlion/vim-solidity'
    use 'neovim/nvim-lspconfig'
    use 'hrsh7th/nvim-cmp'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'saadparwaiz1/cmp_luasnip'
    use 'L3MON4D3/LuaSnip'

    use { 'ms-jpq/coq_nvim', run = 'python3.8 -m coq deps' }
    use 'ms-jpq/coq.artifacts'
    use 'ms-jpq/coq.thirdparty'
end)


local lspconfig = require('lspconfig')
local luasnip = require('luasnip')
local coq = require('coq')
local vim = assert(vim)

--- UTILITY FUNCTION TO INSPECT TABLE
local function print_table(node)
    local cache, stack, output = {},{},{}
    local depth = 1
    local output_str = "{\n"
    local tabulation = "  "
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
                    output_str = output_str .. string.rep(tabulation,depth) .. key .. " = "..tostring(v)
                elseif (type(v) == "table") then
                    output_str = output_str .. string.rep(tabulation,depth) .. key .. " = {\n"
                    table.insert(stack,node)
                    table.insert(stack,v)
                    cache[node] = cur_index+1
                    break
                else
                    output_str = output_str .. string.rep(tabulation,depth) .. key .. " = '"..tostring(v).."'"
                end
                if (cur_index == size) then
                    output_str = output_str .. "\n" .. string.rep(tabulation,depth-1) .. "}"
                else
                    output_str = output_str .. ","
                end
            else
                -- close the table
                if (cur_index == size) then
                    output_str = output_str .. "\n" .. string.rep(tabulation,depth-1) .. "}"
                end
            end
            cur_index = cur_index + 1
        end
        if (size == 0) then
            output_str = output_str .. "\n" .. string.rep(tabulation,depth-1) .. "}"
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
--- END OF FUNCTION


local opts = { noremap=true, silent=true }

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
--"nmap <silent> gy <Plug>(coc-type-definition)
local on_attach = function(client, bufnr)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '[g', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', ']g', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gy', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  --vim.cmd [[autocmd CursorHoldI * silent! lua vim.lsp.buf.signature_help()]]
end



-- Add additional capabilities supported by nvim-cmp
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)



-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = {
  'tsserver',
  'bashls',
  --'sumneko_lua',
  --'omnisharp',
  'vimls',
  'solc',
  'jsonls',
  'dockerls',
  'svelte',
}

-- Automatically start coq
vim.g.coq_settings = { auto_start = 'shut-up' }

-- Enable some language servers with the additional completion capabilities offered by coq_nvim
--local servers = { 'clangd', 'rust_analyzer', 'pyright', 'tsserver' }
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup(coq.lsp_ensure_capabilities({
    on_attach = on_attach,
    flags = {
      -- This will be the default in neovim 0.7+
      debounce_text_changes = 150,
    },
  }))
end

--for _, lsp in pairs(servers) do
--  lspconfig[lsp].setup {
--    on_attach = on_attach,
--    flags = {
--      -- This will be the default in neovim 0.7+
--      debounce_text_changes = 150,
--    },
--    capabilities = capabilities,
--  }
--end


-- nvim-cmp setup.
-- Plugin that draws popup interfaces
-- for autocompletion.
local cmp = require('cmp')
cmp.setup {
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    }),
    ['<Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end,
    ['<S-Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end,
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' }
  },
}
