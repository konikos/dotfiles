let s:amxxpc='amxxpc'

function! SyntaxCheckers_sma_amxxpc_IsAvailable()
    return executable(s:amxxpc)
endfunction

function! SyntaxCheckers_sma_amxxpc_GetLocList()
    let makeprg = syntastic#makeprg#build({
        \ 'exe': s:amxxpc,
        \ 'args': '-n',
        \ 'filetype': 'sma',
        \ 'subchecker': 'amxxpc'})

    let errorformat = '%f(%l) : error %n: %m'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat})
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'sma',
    \ 'name': 'amxxpc'})

