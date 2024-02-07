"function Test()
"    call complete(
"    \    2,
"    \    [ 
"    \        #{
"    \            word: "word",
"    \            abbr: "abbr",
"    \            menu: "menu",
"    \            info: "info",
"    \            kind: "kind"
"    \        },
"    \        #{
"    \            word: "word2",
"    \            abbr: "abbr2",
"    \            menu: "menu2",
"    \            info: "info2",
"    \            kind: "kind2"
"    \        }
"    \    ]
"    \)
"    return ''
"endfunction
"imap <F5> <C-R>=Test()<CR>
"function There()
"    let g:pum_pos = pum_getpos()
"    let g:pum_info = complete_info()
"    "call complete_add("wo")
"    return ''
"endfunction
"imap <F6> <C-R>=There()<CR>
"
"let g:count1 = 0
"let g:count2 = 0
"fun! CompleteMonths(findstart, base)
"  if a:findstart
"    let g:count1 += 1
"    return 0
"  else
"    "let res = []
"    let g:count2 += 1
"    for i in range(1, line('.'))
"        let res = #{
"        \   word: "word" . i,
"        \   abbr: "abbr" . i,
"        \   menu: "menu" . i,
"        \   info: "info" . i,
"        \   kind: "kind" . i
"        \}
"        call complete_add(res)
"
"    endfor
"    return []
"    "return res
"
"    "return [
"    "\        #{
"    "\            word: "word",
"    "\            abbr: "abbr",
"    "\            menu: "menu",
"    "\            info: "info",
"    "\            kind: "kind"
"    "\        },
"    "\        #{
"    "\            word: "word2",
"    "\            abbr: "abbr2",
"    "\            menu: "menu2",
"    "\            info: "info2",
"    "\            kind: "kind2"
"    "\        }
"    "\    ]
"  endif
"endfun
"set omnifunc=CompleteMonths

" 
" 
" func StoreColumn()
"   let g:column = col('.')
"   return 'x'
" endfunc
" nnoremap <expr> x StoreColumn()
" nmap ! f!x
" 
" inoremap <expr> <C-L>x "foo"
" imap ,9 <c-r>=1+1<cr>
" imap <expr> ,8 1+1
" 
" imap <expr> . 1+4
" 
" let g:count = 0
" function Inc()
"     let g:count += 1
"     return g:count
" endfunction
" imap <m-m> <c-r>=Inc()<enter>
