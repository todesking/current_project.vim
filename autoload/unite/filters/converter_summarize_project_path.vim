function! unite#filters#converter_summarize_project_path#define() abort " {{{
	return s:summarize_path
endfunction " }}}

let s:summarize_path = {
			\ 'name': 'converter_summarize_project_path',
			\}
function! s:summarize_path.filter(candidates, context) abort " {{{
	let candidates = copy(a:candidates)
	for cand in candidates
		let cand.word = current_project#summarize_path(cand.word)
		let cand.abbr = cand.word
	endfor
	return candidates
endfunction " }}}

