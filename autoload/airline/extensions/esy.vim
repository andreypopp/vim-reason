" MIT License. Copyright (c) 2013-2018
" vim: et ts=2 sts=2 sw=2

scriptencoding utf-8

function! airline#extensions#esy#GetEsyProjectStatus()
  if exists('g:esyProjectManagerPluginLoaded') && g:esyProjectManagerPluginLoaded==1
    let l:esyLocatedProjectRoot= esy#FetchProjectRootCached()
    if l:esyLocatedProjectRoot == []
      return ''
    else
      let projectInfo = esy#FetchProjectInfoForProjectRootCached(l:esyLocatedProjectRoot)
      if (projectInfo == [] || projectInfo[2] == 'no-esy-field')
        return ''
      else
        let l:displayStatus = ""
        if projectInfo[2] == "uninitialized"
          let l:displayStatus = " [not installed]"
        endif
        if projectInfo[2] == "installed"
          let l:displayStatus = " [not built]"
        endif
        if projectInfo[2] == "invalid"
          let l:displayStatus = " [invalid project]"
        endif
        return esy#ProjectNameOfProjectInfo(l:projectInfo) . l:displayStatus . g:airline_symbols.space . g:airline_right_alt_sep . g:airline_symbols.space
      endif
    endif
  else
    " No esy plugin installed
    return ''
  endif
endfunction


" First we define an init function that will be invoked from extensions.vim
function! airline#extensions#esy#init(ext)

  let doProjectAirline = exists('g:vimreason_project_airline') && g:vimreason_project_airline==1

  if doProjectAirline
    call airline#parts#define_function('projectStatus', 'airline#extensions#esy#GetEsyProjectStatus')
    call airline#parts#define_condition('projectStatus', 'airline#extensions#esy#GetEsyProjectStatus() != ""')
    call airline#parts#define_minwidth('projectStatus', 80)
  endif

  if doProjectAirline
    " Next up we add a funcref so that we can run some code prior to the
    " statusline getting modifed.
    call a:ext.add_statusline_func('airline#extensions#esy#apply')
  endif
endfunction

" This function will be invoked just prior to the statusline getting modified.
function! airline#extensions#esy#apply(...)
  let doProjectAirline = exists('g:vimreason_project_airline') && g:vimreason_project_airline==1
  " I have no idea why, but this is what the example.vim has for airline.
  " Appending to a w: variable.
  if doProjectAirline
    let w:airline_section_z = get(w:, 'airline_section_z', g:airline_section_z)
    if g:vimreason_clean_project_airline==1
      let w:airline_section_z=airline#section#create(['projectStatus', '%3p%%'. g:airline_symbols.space, 'linenr',  ':%3v'])
    else
      let w:airline_section_z=airline#section#create(['projectStatus']) . w:airline_section_z
    endif
  endif
endfunction
