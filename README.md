# current_project.vim: Project information from file path

## Usage

```vim
let info = current_project#info() " returns current buffer's information

" =>
{
\ 'name': 'current_project.vim',
\ 'path': '~/.vim/bundle/current_project.vim',
\ 'main_name': 'current_project.vim',
\ 'main_path': '~/.vim/bundle/current_project.vim',
\ 'sub_name': '',
\ 'sub_path': '~/.vim/bundle/current_project.vim',
\ }

let file_info = current_project#file_info()
```

## Project detection logic

To find project root: `~/projects/`, or search `.git`, `.svn`, `.hg`(see `s:project_root_of()`)

To find subproject: User-defined subproject pattern(see `s:subproject_root()`, `s:subproject_patterns`)

## Setting directory

`~/.current_project.vim/`

## Example

```vim
" e-in-current-project
command! -complete=customlist,current_project#complete -nargs=1 Pe :exec ':e ' . current_project#info().path . '/' . "<args>"
command! -complete=customlist,current_project#complete_main -nargs=1 PE :exec ':e ' . current_project#info().main_path . '/' . "<args>"
```

```vim
" statusline example
function! Vimrc_path_in_statusline()
  let cp = current_project#file_info(expand('%'))
  if empty(cp.name)
	  return expand('%')
  endif
  return '[' . cp.name . '] ' . cp.file_path
endfunction
set statusline=%{Vimrc_path_in_statusline()}
```
