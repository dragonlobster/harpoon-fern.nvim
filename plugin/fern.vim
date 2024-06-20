function! fern#get_path() abort
    let helper = fern#helper#new()

    if helper.sync.get_scheme() !=# 'file'
        return ""
    endif

    let path = helper.sync.get_cursor_node()['_path']

    if isdirectory(path)
        return
    endif
    
    return path
endfunction

function! fern#is_dir() abort
    let helper = fern#helper#new()

    if helper.sync.get_scheme() !=# 'file'
        return 1
    endif

    let path = helper.sync.get_cursor_node()['_path']

    if isdirectory(path)
        return 1
    endif

    return 0

endfunction
