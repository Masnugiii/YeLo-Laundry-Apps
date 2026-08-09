import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_erp/core/providers/core_providers.dart';
import 'package:yelo_laundry_erp/features/customer_service/data/customer_service_repository.dart';
import 'package:yelo_laundry_erp/features/customer_service/models/whatsapp_conversation.dart';

class CustomerServiceListState {
  const CustomerServiceListState({
    required this.conversations,
    required this.summary,
  });

  final List<WhatsappConversation> conversations;
  final CustomerServiceSummary summary;
}

class CustomerServiceListNotifier
    extends AsyncNotifier<CustomerServiceListState> {
  @override
  Future<CustomerServiceListState> build() async {
    return _load();
  }

  Future<CustomerServiceListState> _load({
    String search = '',
    WhatsappConversationFilter filter = WhatsappConversationFilter.semua,
  }) async {
    final repository = ref.read(customerServiceRepositoryProvider);
    final summary = await repository.fetchSummary();
    final response = await repository.fetchTickets(
      search: search,
      category: filterToApiCategory(filter),
      limit: 100,
    );

    final conversations = filterWhatsappConversations(
      conversations: response.items,
      query: search,
      filter: filter,
    );

    return CustomerServiceListState(
      conversations: conversations,
      summary: summary,
    );
  }

  Future<void> refresh({
    String search = '',
    WhatsappConversationFilter filter = WhatsappConversationFilter.semua,
  }) async {
    state = const AsyncLoading();
    state = AsyncData(await _load(search: search, filter: filter));
  }

  Future<void> updateCategory({
    required WhatsappConversation conversation,
    required WhatsappMessageCategory category,
    String search = '',
    WhatsappConversationFilter filter = WhatsappConversationFilter.semua,
  }) async {
    await ref.read(customerServiceRepositoryProvider).updateTicketCategory(
          id: conversation.id,
          category: category,
        );
    await refresh(search: search, filter: filter);
  }
}

final customerServiceListProvider = AsyncNotifierProvider<
    CustomerServiceListNotifier, CustomerServiceListState>(
  CustomerServiceListNotifier.new,
);

final customerServiceDetailProvider =
    FutureProvider.family<WhatsappConversation?, String>((ref, id) async {
  return ref.read(customerServiceRepositoryProvider).fetchTicketDetail(id);
});

final customerServiceUnreadCountProvider = FutureProvider<int>((ref) async {
  final summary =
      await ref.watch(customerServiceRepositoryProvider).fetchSummary();
  return summary.unreadMessages;
});
