package com.empresa.projeto.pedidos.adapter;

import com.empresa.projeto.pedidos.domain.Pedido;
import com.empresa.projeto.pedidos.domain.PedidoRepository;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class PedidoJpaAdapter implements PedidoRepository {
  private final PedidoJpaRepository jpa;

  @Override
  public Pedido salvar(Pedido pedido) {
    var entity = PedidoEntity.from(pedido);
    return jpa.save(entity).toDomain();
  }

  @Override
  public Optional<Pedido> buscarPorId(String id) {
    return jpa.findById(id).map(PedidoEntity::toDomain);
  }
}
