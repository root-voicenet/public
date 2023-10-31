explain select t.* from (
                    select
                        iol.id as iol_id,
                        iol.from_ip as iol_from_ip,
                        iol.from_port as iol_from_port,
                        iol.url as iol_url,
                        iol.method as iol_method,
                        iol.request_time as iol_request_time,
                        iol.route_id as iol_route_id,
                        iol.to_host as iol_to_host,
                        iol.to_port as iol_to_port,
                        iol.response_status_code as iol_response_status_code,
                        iol.created_at as iol_created_at,
                        iol.created_day_at as iol_created_day_at,
                        bool_or(hrl_in.check_status = 'FAIL') as request_check_status_fail,
                        bool_or(hrl_out.check_status = 'FAIL') as response_check_status_fail
                    from access_log iol
                             left join http_request_log as hrl_in on hrl_in.check_id_income = iol.income_check_id and hrl_in.check_id_outcome is null
                             left join http_request_log as hrl_out on hrl_out.check_id_outcome = iol.outcome_check_id
                    where
                        iol.created_day_at between '2023-10-30' and '2023-10-31'
                      and (null is null or iol.from_ip  = null)
                      and (null is null or iol.from_port = null)
                      and (null is null or iol.to_host = null)
                      and (null is null or iol.to_port = null)
                      and ('top' is null or iol.path <@ text2ltree('top'))
                      and (null is null or iol.url like null || '%%')
                      and (null is null or iol.url like null || '%%')
                      and (iol.method in ('GET', 'POST', 'PUT'))

        and (1=1 and (iol.response_status_code not in (200)) )

    group by iol_id, iol_from_ip, iol_from_port, iol_url, iol_method, iol_request_time, iol_route_id, iol_to_host, iol_to_port, iol_response_status_code, iol_created_at, iol_created_day_at
    order by iol.id desc
) t
where 1 = 1
and (null is null or t.request_check_status_fail = null::bool)
and (null is null or t.response_check_status_fail = null::bool)
limit 10 offset 0
