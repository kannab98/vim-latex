"Author:    Kirill Ponur    
"------------------------------------------------------------
" 1. Plugins
"------------------------------------------------------------

augroup TeXautocmd
  autocmd!
" Russian and English spellchecking
  "autocmd BufEnter           *.tex set spell spelllang=ru,en_us
  autocmd BufEnter           *.tex set spell spelllang=ru,en_us
  autocmd CursorMovedI       *.tex call ToggleLangMap()
  autocmd CursorHoldI        *.tex call ToggleLangMap()
  autocmd InsertEnter        *.tex call ToggleLangMap()
  "autocmd InsertLeave  *.tex call ToggleLangMap()
  "autocmd TextChangedI *.tex call ToggleLangMap()
augroup END

"------------------------------------------------------------
"2.TeX Settings                                             
"------------------------------------------------------------
let g:tex_flavor='latex'
let g:vimtex_quickfix_mode=0
let g:vimtex_complete_enabled=1
set conceallevel=2
let g:tex_conceal="abdgm"
let g:vimtex_latexmk_options = '-pdf -shell-escape -verbose -bibtex -file-line-error -syntex=1 -interaction=nonstopmode'
let g:vimtex_view_general_viewer = 'okular'
let g:vimtex_view_general_options = '--noraise --unique file:@pdf\#src:@line@tex'
let g:vimtex_view_general_options_latexmk = '--unique'
inoremap <C-f> <Esc>: silent exec '.!inkscape-figures create "'.getline('.').'" "'.b:vimtex.root.'/fig/"'<CR><CR>:w<CR>
nnoremap <C-f> : silent exec '!inkscape-figures edit "'.b:vimtex.root.'/figures/" > /dev/null 2>&1 &'<CR><CR>:redraw!<CR>

"------------------------------
"2.1. Map definitions
"------------------------------
nnoremap <localleader>env :echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")') <CR>
" Return to last mistake and fix it
inoremap <C-l> <c-g>u<Esc>[s1z=`]a<c-g>u
nnoremap <C-l> i<c-g>u<Esc>[s1z=`]a<c-g>u<Esc>
"------------------------------
"2.2. Autochange keyboard layout
"------------------------------
if has('unix')
"begin{ToggleLangMap}
"let g:airline_section_c = 'was_ru=%{g:was_ru}, iminsert=%{&iminsert}, layout=%{g:lay}'
function! ReturnToVim()
  call remote_foreground(v:servername)
endfunction

let g:was_ru = 2
let g:lay = libcall(g:XkbSwitchLib, 'Xkb_Switch_getXkbLayout', '')
let g:lay='ru'
"0 -- If when entered math mode language was English
"1 -- If when entered math mode language was Russian
"2 -- Language not detected 

function! Layout(lang)
  call libcall(g:XkbSwitchLib, 'Xkb_Switch_setXkbLayout', a:lang)
endfunction

function! RememberLayout()
  if g:was_ru == 2
    if g:lay != 'us'
      let g:was_ru = 1
    elseif g:lay == 'us'
      let g:was_ru = 0
    endif
  endif
endfunction

function! SwitchLayout()
  if g:was_ru==1
      call Layout('ru')
      let g:was_ru=2
  elseif g:was_ru==0
      call Layout('us')
      let g:was_ru=2
  endif

endfunction!

function! ToggleLangMap()
  let l:mathmode = vimtex#util#in_mathzone()
  let l:mathtext = vimtex#util#in_syntax('texMathText')
  let g:lay = libcall(g:XkbSwitchLib, 'Xkb_Switch_getXkbLayout', '')

  if mode()=='i'
    if l:mathmode == 1 
      call RememberLayout()
      if l:mathtext == 0
        call Layout('us')
      elseif l:mathtext == 1
        call SwitchLayout()
      endif
    else   
      call SwitchLayout()
    endif
  endif 


endfunction
endif
"end{ToggleLangMap}
"
function! FigTemplate()
    execute ":r ~/.dotfiles/templates/tex/fig.tex"
endfunction

function! OkularRC()
    let s:f='%f'
    let s:l='%l'
    exec ":!sed 's/.*ExternalEditorCommand=.*/ExternalEditor=/g" . s:f. "'~/.config/okularpartrc" 
endfunction

