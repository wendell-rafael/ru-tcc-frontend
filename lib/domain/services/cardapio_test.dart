import 'package:rutccc/data/models/cardapio.dart';
import 'cardapio_service.dart';

final cardapioService = CardapioService();

void testCardapioCrud() async {
  // ✅ Criar novo cardápio
  final novoCardapio = Cardapio(
    id: 0,
    dia: 15,
    refeicao: 'Almoço',
    opcao1: 'Frango grelhado',
    opcao2: 'Peixe assado',
  );
  await cardapioService.createCardapio(novoCardapio);
  print('✅ Cardápio criado com sucesso!');

  // ✅ Listar cardápios
  List<Cardapio> cardapios = await cardapioService.getCardapios();
  print('📜 Cardápios recebidos: ${cardapios.length}');

  // ✅ Atualizar cardápio
  final atualizado = Cardapio(
    id: cardapios.first.id,
    dia: 15,
    refeicao: 'Jantar',
    opcao1: 'Carne de panela',
    opcao2: 'Salada Caesar',
  );
  await cardapioService.updateCardapio(cardapios.first.id, atualizado);
  print('✏️ Cardápio atualizado!');

  // ✅ Obter cardápio por ID
  Cardapio cardapioDetalhes = await cardapioService.getCardapioById(cardapios.first.id);
  print('🔍 Detalhes: ${cardapioDetalhes.refeicao}');

  // ✅ Remover cardápio
  await cardapioService.deleteCardapio(cardapios.first.id);
  print('🗑️ Cardápio removido!');
}
