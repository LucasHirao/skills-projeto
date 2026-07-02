-- Exemplo incremental merge com lookback (ver ADR docs/adr/0001)
{% if is_incremental() %}
  {% set lookback = var('lookback_days', 3) %}
{% endif %}
select *
from {{ ref('int_vendas__pedidos_enriquecidos') }}
{% if is_incremental() %}
where data_atualizacao >= dateadd(day, -{{ lookback }}, current_date)
{% endif %}
