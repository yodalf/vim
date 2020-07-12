" Vim support file containing scripts specific to occam
"
" Maintainer:	Mario Schweigler <ms44@kent.ac.uk>
" Last Change:	23 April 2003

" Only load this file once
if exists("b:did_occammacros")
  finish
endif
let b:did_occammacros = 1

"{{{  User defined commands

" Compile with KRoC
" Argument: Optionally additional KRoC options
command -nargs=? Kroccompile call <SID>KrocCompile(<q-args>)

" Goto source line
command Gotosourceline call <SID>GotoSourceLine()

" Run occam program
" Argument: Optionally additional running parameters
command -nargs=? Runoccamprogram call <SID>RunOccamProgram(<q-args>)

" Toggle file type
command Toggleoccamfiletype call <SID>ToggleOccamFileType()

"{{{  Shortcuts for the commands
command -nargs=? KC Kroccompile <args>
command GS Gotosourceline
command -nargs=? RO Runoccamprogram <args>
command TOF Toggleoccamfiletype
"}}}

"}}}

"{{{  Keyboard mappings

"{{{  Compile and run occam programs
" F5 is Compile with KRoC
noremap <silent><F5> :Kroccompile<CR>
onoremap <F5> <Esc>
vnoremap <silent><F5> <Esc>:Kroccompile<CR>
inoremap <silent><F5> <Esc>:Kroccompile<CR>

" Ctrl-F5 is Run occam program
noremap <silent><C-F5> :Runoccamprogram<CR>
onoremap <C-F5> <Esc>
vnoremap <silent><C-F5> <Esc>:Runoccamprogram<CR>
inoremap <silent><C-F5> <Esc>:Runoccamprogram<CR>
"}}}

"{{{  Toggle file type
" F6 toggles file type between occam and off
noremap <silent><F6> :Toggleoccamfiletype<CR>
onoremap <F6> <Esc>
vnoremap <silent><F6> <Esc>:call <SID>ToggleOccamFileType()<CR>
inoremap <silent><F6> <C-O>:call <SID>ToggleOccamFileType()<CR>
"}}}

"}}}

"{{{  function <SID>KrocCompile(options)
" Function to compile a file with KRoC and put the output in a new window
" Arguments: a:options are additional KRoC options (optional)
function <SID>KrocCompile(options)

  " Stop if filetype is not occam
  if &filetype != 'occam' || exists("b:is_compileroutput")
    echohl ErrorMsg
    echomsg 'Error: No occam file'
    echohl None
    return
  endif

  " Save current file if modified
  if &modified
    if expand('%') == ''
      if has('gui_running')
        browse confirm w
      else
        echohl ErrorMsg
        echomsg "Error: Can't save file: No file name"
        echohl None
        return
      endif
    else
      confirm w
    endif
  endif

  " Stop if file has not been saved
  if &modified || expand('%') == ''
    echohl ErrorMsg
    echomsg 'Error: File not saved'
    echohl None
    return
  endif

  " Store whether we have entered a fold
  let tempfoldentered = exists('b:is_foldentered')

  " Store name of swap file containing start of file
  if tempfoldentered
    let tempstartfilename = b:foldentered_swapfilename . '.fold.1.pre'
  endif

  " Get information about line offset
  if exists('b:is_foldentered')
    let lineoffset = b:foldentered_lineoffset_sum
    let lastline = line('$')
  else
    let lineoffset = -1
  endif

  " Store filename and directory of current file
  let tempfilename = fnamemodify(bufname('%'), ':t')
  let tempdir = fnamemodify(bufname('%'), ':p:h')

  " Save current directory
  let curdir = fnamemodify('', ':p')

  " Get buffer number
  let tempbufname = expand('%')

  " Get general compiler options from environment variable
  let myoptions = $OCOPTIONS

  " Ensure magic is on
  let save_magic = &magic
  setlocal magic

  " If we are in a fold
  if tempfoldentered
    " Open a new window
    new

    " The new buffer is modifiable
    setlocal modifiable

    " Don't create alternate files
    let save_cpo = &cpoptions
    setlocal cpoptions-=aA

    " Read in start of file
    exe 'silent 0 read ' . AdaptFileName(tempstartfilename)

    " Restore cpoptions
    exe 'setlocal cpoptions=' . save_cpo
  endif

  " Check whether the file is a library
  let firstline = getline(1)
  let islib = firstline =~ '^\s*--\s*KROC-LIBRARY\(\.so\|\.a\)\=\s*$'
  if islib

    let islibdota = firstline =~ 'KROC-LIBRARY\.a'

    if myoptions !~ '^\s*$'
      let myoptions = ' ' . myoptions
    endif
    let myoptions = '-c' . myoptions
    let firstline = getline(2)
  endif

  " Get compiler options from current file (primarily for used libraries)
  if firstline =~ '^\s*--\s*KROC-OPTIONS:.*'
    if myoptions !~ '^\s*$'
      let myoptions = myoptions . ' '
    endif
    let myoptions = myoptions . substitute(firstline, '^\s*--\s*KROC-OPTIONS:\s*', '', 'g')
  endif

  " If we are in a fold
  if tempfoldentered

    " Empty window
    silent % d _

  else
    " Open a new window
    new

    " The new buffer is modifiable
    setlocal modifiable
  endif

  " Mark this window as a compiler output window
  let b:is_compileroutput = 1

  " Save buffer number of source window
  let b:sourcebufname = tempbufname

  " Add parameters from cmdline
  if a:options != ''
    if myoptions !~ '^\s*$'
      let myoptions = myoptions . ' '
    endif
    let myoptions = myoptions . a:options
  endif

  " First line in compiler output window
  call append(0, '-- Compiled File: "' . tempfilename . '"')

  " Show options
  if myoptions !~ '^\s*$'
    let myoptions = ' ' . myoptions
    call append(1, '-- Options:' . myoptions)
  endif

  " Change to directory of file to compile
  exe 'cd ' . AdaptFileName(tempdir)
  " Run KRoC and place output in window
  exe 'silent $ read ! kroc ' . AdaptFileName(tempfilename) . myoptions

  " Additional commands if it is a library
  if !v:shell_error && islib

    " Remove extension
    let tfn = fnamemodify(tempfilename, ':r')

    exe 'silent $ read ! ilibr ' . AdaptFileName(tfn) . '.tce -o ' . AdaptFileName(tfn) . '.lib'
    if islibdota
      " .a library
      exe 'silent $ read ! ar rcu lib' . AdaptFileName(tfn) . '.a ' . AdaptFileName(tfn) . '.o'
      exe 'silent $ read ! ranlib lib' . AdaptFileName(tfn) . '.a'
    else
      " Shared library
      exe 'silent $ read ! ld -r -o lib' . AdaptFileName(tfn) . '.so ' . AdaptFileName(tfn) . '.o'
    endif
    exe 'silent $ read ! rm ' . AdaptFileName(tfn) . '.tce'
    exe 'silent $ read ! rm ' . AdaptFileName(tfn) . '.o'
  endif

  " Adapt to line offset if we are inside a fold
  if lineoffset != -1

    " Each line
    let i = 0
    while line('$') > i
      let i = i + 1

      " Get line
      let line = getline(i)

      " First kind of pattern
      let me = matchend(line, '\V' . tempfilename . '(\d\+)')
      if me != -1

        " Get the line number
        let nr = matchstr(line, '\<\d*\%' . (me) . 'c\d*\>')
        " Check whether line is in currently entered fold
        if (nr > lineoffset) && (nr <= lineoffset + lastline)

          " Local line number
          let lonr = nr - lineoffset

          let line = strpart(line, 0, me - 1) . '>' . lonr . strpart(line, me - 1)
          call setline(i, line)

        endif

      " Second kind of pattern
      else

        let me = matchend(line, '\V"' . tempfilename . '" lines\= \d\+')

        while me != -1
          " Get the line number
          let nr = matchstr(line, '\<\d*\%' . (me) . 'c\d*\>')
          let ms = match(line, '\<\d*\%' . (me) . 'c\d*\>')
          " Check whether line is in currently entered fold
          if (nr > lineoffset) && (nr <= lineoffset + lastline)

            " Local line number
            let lonr = nr - lineoffset

            let line = strpart(line, 0, ms) . '(' . nr . '>' . lonr . ')' . strpart(line, me)
            call setline(i, line)
            let me = me + strlen(lonr) + 3

          endif

          " Next number
          let me = matchend(line, '\d\+', me)
        endwhile
      endif

    endwhile
  endif

  " Go to first line
  normal gV
  goto
  " Disable folding
  normal zn
  " Highlight in occam style
  setf occam
  " Disable line numbers
  setlocal nonumber

  " Window cannot be modified and can be closed without saving
  setlocal nomodified
  setlocal nomodifiable

  " Go back to old directory
  exe 'cd ' . AdaptFileName(curdir)

  " Restore magic
  if !save_magic|setlocal nomagic|endif

endfunction
"}}}

"{{{  function <SID>GotoSourceLine()
" If there is a valid line number under the cursor,
" this functions switches to the source code window and puts the cursor on that line
function <SID>GotoSourceLine()

  " Stop if this is not a compiler output window
  if !exists("b:is_compileroutput")
    echohl ErrorMsg
    echomsg 'Error: Not in a compiler output window'
    echohl None
    return
  endif

  " Ensure magic is on
  let save_magic = &magic
  setlocal magic

  " Get word under the cursor
  let curword = matchstr(getline('.'), '>\=\<\d*\%' . col('.') . 'c\d*\>')

  " Get buffer number
  let tempbufnr = bufnr('%')

  " Check if it is a positive number
  if matchstr(curword, '\<\d*\>') > 0

    if bufwinnr(b:sourcebufname) != -1

      " Switch to source window
      exe bufwinnr(b:sourcebufname) . 'wincmd w'

      " If this is a "local" line number
      if strpart(curword, 0, 1) == '>'

        if curword <= line('$')
          " Goto the line we just found out
          exe 'normal ' . strpart(curword, 1) . 'G'
          normal gV
        else
          " Switch back to compiler output window
          exe bufwinnr(tempbufnr) . 'wincmd w'
          echohl ErrorMsg
          echomsg 'No valid line number under cursor'
          echohl None
        endif

      " This is a "global" line number  
      else

        " Find out line offset
        if exists('b:foldentered_lineoffset_sum')
          let lineoffset = b:foldentered_lineoffset_sum
        else
          let lineoffset = 0
        endif

        " If line number is inside the text
        if curword > lineoffset && curword - lineoffset <= line('$')
          " Goto the line we just found out
          exe 'normal ' . (curword - lineoffset) . 'G'
          normal gV
        else
          " Switch back to compiler output window
          exe bufwinnr(tempbufnr) . 'wincmd p'
          echohl ErrorMsg
          echomsg 'No valid line number under cursor'
          echohl None
        endif
      endif

    else
      echohl ErrorMsg
      echomsg 'Error: Source code window no longer present'
      echohl None
    endif

  else
    echohl ErrorMsg
    echomsg 'No valid line number under cursor'
    echohl None
  endif

  " Restore magic
  if !save_magic|setlocal nomagic|endif

endfunction
"}}}

"{{{  function <SID>RunOccamProgram(parameters)
" Function to run an occam program (ONLY works for programs which ONLY output FINITE amounts of TEXT!)
" Do NOT use this for programs which use Escape sequences to place text on the screen!
" Do NOT use this for programs which use graphics!
" Do NOT use this for programs which require input!
" Do NOT use this for programs which output infinite amounts of text!
" Arguments: a:parameters are additional running parameters (optional)
function <SID>RunOccamProgram(parameters)

  " Stop if filetype is not occam
  if &filetype != 'occam'
    echohl ErrorMsg
    echomsg 'Error: No occam file'
    echohl None
    return
  endif

  " Stop if there is no file name
  if expand('%') == ''
    echohl ErrorMsg
    echomsg 'Error: No file name'
    echohl None
    return
  endif

  " Store whether we have entered a fold
  let tempfoldentered = exists('b:is_foldentered')

  " Store name of swap file containing start of file
  if tempfoldentered
    let tempstartfilename = b:foldentered_swapfilename . '.fold.1.pre'
  endif

  " Store filename (without extension) and directory of current file
  let tempfilename = fnamemodify(bufname('%'), ':t:r')
  let tempdir = fnamemodify(bufname('%'), ':p:h')

  " Save current directory
  let curdir = fnamemodify('', ':p')

  " Store modified flag
  let modified = &modified

  " Ensure magic is on
  let save_magic = &magic
  setlocal magic

  " If we are in a fold
  if tempfoldentered
    " Open a new window
    new

    " The new buffer is modifiable
    setlocal modifiable

    " Don't create alternate files
    let save_cpo = &cpoptions
    setlocal cpoptions-=aA

    " Read in start of file
    exe 'silent 0 read ' . AdaptFileName(tempstartfilename)

    " Restore cpoptions
    exe 'setlocal cpoptions=' . save_cpo
  endif

  " Check whether the file is a library
  let firstline = getline(1)
  let islib = firstline =~ '^\s*--\s*KROC-LIBRARY\(\.so\|\.a\)\=\s*$'

  let myparameters = ''

  if !islib
    " Read next line if there are compiler options
    if firstline =~ '^\s*--\s*KROC-OPTIONS:.*'
      let firstline = getline(2)
    endif

    " Get running parameters from current file (primarily for used libraries)
    if firstline =~ '^\s*--\s*RUN-PARAMETERS:.*'
      let myparameters = substitute(firstline, '^\s*--\s*RUN-PARAMETERS:\s*', '', 'g')
    endif
  endif

  " If we are in a fold
  if tempfoldentered

    " Empty window
    silent % d _

  else
    " Open a new window
    new

    " The new buffer is modifiable
    setlocal modifiable
  endif

  " Change to directory of file to run
  exe 'cd ' . AdaptFileName(tempdir)

  " Check whether executable exists
  let fileexists = filereadable(tempfilename)

  " If error occurred
  if islib || !fileexists

    " Go back to old directory
    exe 'cd ' . AdaptFileName(curdir)

    " Close temporary buffer
    bdelete!
    redraw

    " Print error message
    echohl ErrorMsg
    if islib
      echomsg 'Error: Cannot run a library'
    else
      echomsg 'Error: Source file has not been compiled yet'
    endif
    echohl None

    " Restore magic
    if !save_magic|setlocal nomagic|endif

    return
  endif

  " Add parameters from cmdline
  if a:parameters != ''
    if myparameters !~ '^\s*$'
      let myparameters = myparameters . ' '
    endif
    let myparameters = myparameters . a:parameters
  endif

  " First line in output window
  call setline(1, 'Running: "' . tempfilename . '"')

  " Show parameters
  if myparameters !~ '^\s*$'
    let myparameters = ' ' . myparameters
    call append(line('$'), 'Running parameters:' . myparameters)
  endif

  call append(line('$'), '')

  " Print warning if file is modified
  if modified
    call append(line('$'), 'Warning: Source file has been modified since compilation')
    call append(line('$'), '')
  endif

  " Run executable
  exe 'silent $ read ! ./' . AdaptFileName(tempfilename) . myparameters

  " Remove 's at the ends of lines
  silent! % s /$/

  " Go to first line
  normal gV
  goto
  " Disable folding
  normal zn

  " Window cannot be modified and can be closed without saving
  setlocal nomodified
  setlocal nomodifiable

  " Go back to old directory
  exe 'cd ' . curdir

  " Restore magic
  if !save_magic|setlocal nomagic|endif

endfunction
"}}}

"{{{  function <SID>ToggleOccamFileType()
" Function to toggle the filetype of a buffer between occam and none
function <SID>ToggleOccamFileType()
  if &filetype == ''

    " Start from scratch
    if exists('b:current_syntax')
      unlet b:current_syntax
    endif
    if exists('b:did_indent')
      unlet b:did_indent
    endif
    if exists('b:did_ftplugin')
      unlet b:did_ftplugin
    endif

    " Set filetype
    setf occam
    echomsg "File type is now occam"
  else
    let &filetype = ''

    " Start from scratch
    if exists('b:current_syntax')
      unlet b:current_syntax
    endif
    if exists('b:did_indent')
      unlet b:did_indent
    endif
    if exists('b:did_ftplugin')
      unlet b:did_ftplugin
    endif

    syn clear
    call SetFoldSyntax()
    call SetCommentstring()

    setlocal shiftwidth&
    setlocal softtabstop&
    setlocal expandtab&
    setlocal iskeyword&

    setlocal indentexpr&
    setlocal indentkeys&

    echomsg "File type turned off"
  endif
endfunction
"}}}

