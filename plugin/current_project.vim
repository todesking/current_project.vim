command! -nargs=0 CurrentProjectSubPatternList call current_project#sub_pattern_list()
command! -nargs=0 CurrentProjectLoadSettings call current_project#load_settings()
command! -nargs=0 CurrentProjectSaveSettings call current_project#save_settings()
command! -nargs=0 CurrentProjectClearSubPatterns call current_project#clear_sub_patterns()
command! -nargs=0 CurrentProjectClearCache call current_project#clear_cache()
command! -nargs=1 -complete=customlist,current_project#complete_main CurrentProjectAddSubPattern call current_project#add_subproject_pattern(<f-args>)

augroup current_project
	autocmd!
	autocmd VimLeavePre * call current_project#save_settings()
augroup END

call current_project#load_settings()

