--vim.lsp.start({
--	name = 'my-server-name-12',
--	cmd = {'typescript-language-server', '--stdio'},
--	root_dir = vim.fs.dirname(vim.fs.find({'index.ts'}, { upward = true })[1])
--})
vim.lsp.start({
	name = 'my-server-name-12',
	cmd = {'omnisharp', '--languageserver' },
	root_dir = vim.fs.dirname(vim.fs.find({'Program.cs'}, { upward = true })[1]),
	settings = {
		enable_editorconfig_support = true,
		enable_roslyn_analyzers     = false,
		enable_import_completion    = true,
	}

})

vim.diagnostic.handlers["my/notify"] = {
	show = function()
		print("show")
	end,
	hide = function()
		print("hide")
	end
}
-- usful command
-- setloclist({opts})                               *vim.diagnostic.setloclist()*
-- setqflist({opts})                                 *vim.diagnostic.setqflist()*


vim.lsp.handlers["textDocument/completion"] = function(arg1, arg2, arg3)
	vim.g.arg1 = arg1;
	vim.g.arg2 = arg2;
	vim.g.arg3 = arg3
end

vim.api.nvim_buf_set_keymap(0, 'i', '<C-x><C-z>', '<cmd>lua vim.lsp.buf.completion()<CR>', {})

function write(variable, filename)
	local file = io.open(filename, "w")
	local table = {
		date = os.date(),
		variable = variable,
	}
	local output = print_table(table)
	file:write(output)
end

function connect()
	vim.lsp.buf_attach_client(0, 1);
end

function tprint (tbl, indent)
  if not indent then indent = 0 end
  for k, v in pairs(tbl) do
    formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      print(formatting)
      tprint(v, indent+1)
    elseif type(v) == 'boolean' then
      print(formatting .. tostring(v))      
    else
      print(formatting .. v)
    end
  end
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
    return output_str
end

