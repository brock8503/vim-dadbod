function! db#adapter#bigquery#auth_input() abort
  return v:false
endfunction

function! s:command_for_url(url, subcmd) abort
  let cmd = ['bq']
  let parsed = db#url#parse(a:url)

  if has_key(parsed, 'opaque')
    let g:bigquery_host_targets = split(substitute(parsed.opaque, '/', '', 'g'), ':')

    " If the host is specified as bigquery:project:dataset, then parse
    " the optional (project, dataset) to supply them to the CLI.
    if len(g:bigquery_host_targets) == 2
      call add(cmd, '--project_id=' . g:bigquery_host_targets[0])
      call add(cmd, '--dataset_id=' . g:bigquery_host_targets[1])
    elseif len(g:bigquery_host_targets) == 1
      call add(cmd, '--project_id=' . g:bigquery_host_targets[0])
    endif
  endif

  for [k, v] in items(parsed.params)
    let op = '--'.k.'='.v
    call add(cmd, op)
  endfor
  return cmd + [a:subcmd]
endfunction

function! db#adapter#bigquery#filter(url) abort
  return extend(s:command_for_url(a:url, 'query'), ['--use_legacy_sql=false', '--max_rows=100000'])
endfunction

function! db#adapter#bigquery#interactive(url) abort
  return extend(s:command_for_url(a:url, 'query'), ['--use_legacy_sql=false', '--format=csv', '--max_rows=100000'])
endfunction

function! db#adapter#bigquery#tables(url) abort
  return map(db#systemlist(s:command_for_url(a:url, 'ls'))[2:],
        \ {_, val -> substitute(val, '\s', '', 'g')})
endfunction
