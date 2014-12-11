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
```

## Project detection logic

To find project root: `~/projects/`, or search `.git`, `.svn`, `.hg`(see `s:project_root_of()`)

To find subproject: User-defined subproject pattern(see `s:subproject_root()`, `s:subproject_patterns`)

## Setting directory

`~/.current_project.vim/`
