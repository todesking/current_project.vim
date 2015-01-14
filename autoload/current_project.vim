" file_path:h => project_info
let s:project_cache = {}

" project_root => [subproject_root_pat]
let s:subproject_patterns = {}

" for persistent purpose
let s:subproject_patterns_orig = {}

let s:default_project_container_dirs = [
	\ fnamemodify('~/projects/', ':p'),
\ ]

let s:setting_dir = fnamemodify('~/.current_project.vim', ':p')

let s:project_root_filenames = ['.git', '.svn', '.hg']

" Utility {{{
function! s:starts_with(str, prefix) abort " {{{
	return len(a:prefix) <= len(a:str) && a:prefix == a:str[0:len(a:prefix) - 1]
endfunction " }}}
" }}}

let s:empty_project_info = {
\  'name': '',
\  'main_name': '',
\  'sub_name': '',
\  'path': '',
\  'main_path': '',
\  'sub_path': '',
\}

function! current_project#file_info(file) abort " {{{
	let pinfo = copy(current_project#info(a:file))
	let pinfo.file_path = substitute(fnamemodify(a:file, ':p'), '^\V' . escape(pinfo.path, '/') . '/', '', '')
	return pinfo
endfunction " }}}

function! current_project#info(...) abort " {{{
	if a:0 == 0
		let file_path = expand('%:p')
	elseif a:0 == 1
		let file_path = fnamemodify(a:1, ':p')
	else
		throw 'Illegal argument size(expected 0 or 1):' . a:0
	endif

	if empty(file_path)
		return s:empty_project_info
	endif

	if has_key(s:project_cache, file_path)
		return s:project_cache[file_path]
	endif

	if !isdirectory(file_path)
		let dir = fnamemodify(file_path, ':p:h')
		if has_key(s:project_cache, dir)
			let s:project_cache[file_path] = s:project_cache[dir]
			return s:project_cache[dir]
		endif
	else
		let dir = file_path
	endif

	let project_root = s:project_root_of(file_path)
	let sub_project_name = s:subproject_name(project_root, file_path)
	let main_project_name = fnamemodify(project_root, ':t')
	let name = main_project_name
	let path = project_root
	if !empty(sub_project_name)
		let name .= '/'.sub_project_name
		let path .= '/'.sub_project_name
	endif

	let info = {
	\  'name': name,
	\  'main_name': main_project_name,
	\  'sub_name': sub_project_name,
	\  'path': path,
	\  'main_path': project_root,
	\  'sub_path': path,
	\}

	let s:project_cache[dir] = info
	let s:project_cache[file_path] = info

	return info
endfunction " }}}

function! current_project#clear_cache() abort " {{{
	let s:project_cache = {}
endfunction " }}}

function! current_project#add_subproject_pattern(pat) abort " {{{
	let info = current_project#info()
	let s:subproject_patterns[info.main_path] = add(get(s:subproject_patterns, info.main_path, []), a:pat)
	call current_project#clear_cache()
endfunction " }}}

function! current_project#save_settings() abort " {{{
	if s:subproject_patterns == s:subproject_patterns_orig
		return
	endif
	let lines = []
	for root in keys(s:subproject_patterns)
		for pat in s:subproject_patterns[root]
			let lines += [root . "\t" . pat]
		endfor
	endfor
	if(!getftype('s:setting_dir') == 'dir')
		call mkdir(s:setting_dir, 'p')
	endif
	call writefile(lines, s:setting_dir . '/subproject.tsv')
endfunction " }}}

function! current_project#load_settings() abort " {{{
	let file = s:setting_dir . '/subproject.tsv'
	let s:subproject_patterns = {}
	let s:subproject_patterns_orig = {}
	if(getftype(file) != 'file')
		return
	endif
	let lines = readfile(file)
	for l in lines
		let [root, pat] = split(l, "\t", 1)
		let s:subproject_patterns[root] = add(get(s:subproject_patterns, root, []), pat)
	endfor
	let s:subproject_patterns_orig = copy(s:subproject_patterns)
	call current_project#clear_cache()
endfunction " }}}

function! current_project#subproject_patterns(...) abort " {{{
	let info = call('current_project#info', a:000)
	return get(s:subproject_patterns, info.main_path, [])
endfunction " }}}

function! current_project#complete(ArgLead, CmdLine, CursorPos) abort " {{{
	let prefix = current_project#info(expand('%')).path
	return s:complete_dir(prefix, a:ArgLead, a:CmdLine, a:CursorPos)
endfunction " }}}

function! current_project#complete_main(ArgLead, CmdLine, CursorPos) abort " {{{
	let prefix = current_project#info(expand('%')).main_path
	return s:complete_dir(prefix, a:ArgLead, a:CmdLine, a:CursorPos)
endfunction " }}}

function! current_project#clear_sub_patterns() abort " {{{
	let info = current_project#info()
	if has_key(s:subproject_patterns, info.main_path)
		call remove(s:subproject_patterns, info.main_path)
	endif
endfunction " }}}

function! current_project#sub_pattern_list() abort " {{{
	let info = current_project#info()
	let patterns = get(s:subproject_patterns, info.main_path, [])
	if empty(patterns)
		echo 'No subproject patterns for ' . info.main_path
	else
		echo 'Subproject patterns for ' . info.main_path . ':'
		for pat in patterns
			echo '  ' . pat
		endfor
	endif
endfunction " }}}

" @vimlint(EVL103, 1)
function! s:complete_dir(prefix, ArgLead, CmdLine, CursorPos) abort " {{{
	let prefix = a:prefix . '/'
	let candidates = glob(prefix . a:ArgLead . '*', 1, 1)
	let result = []
	for c in candidates
		if isdirectory(c)
			call add(result, substitute(c, prefix, '', '') . '/')
		else
			call add(result, substitute(c, prefix, '', ''))
		endif
	endfor
	return result
endfunction  " }}}
" @vimlint(EVL103, 0)

function! s:project_root_of(dir) abort " {{{
	let d = fnamemodify(a:dir, ':p')
	while fnamemodify(d, ':h') != d
		for f in s:project_root_filenames
			let path = d . '/' . f
			if isdirectory(path) || filereadable(path)
				return substitute(d, '/$', '', '')
			endif
		endfor
		let d = fnamemodify(d, ':h')
	endwhile
	return ''
endfunction " }}}

function! s:subproject_name(root, path) abort abort " {{{
	let relpath = matchstr(fnamemodify(a:path, ':p'), '^\V' . escape(a:root, '\') . '/\v\zs[^/]+\/.*\ze')
	for sr in get(s:subproject_patterns, a:root, [])
		let m = matchlist(relpath, sr)
		if !empty(m)
			return m[0]
		endif
	endfor
	return ''
endfunction " }}}
