command! -nargs=0 CurrentProjectSubPatternList call current_project#sub_pattern_list()
command! -nargs=0 CurrentProjectLoadSettings call current_project#load_settings()

augroup current_project
	autocmd!
	autocmd VimLeavePre * call current_project#save_settings()
augroup END

call current_project#load_settings()

