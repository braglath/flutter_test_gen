class CounterRepository {
  int getCount() => 1;
}

class CounterViewModel {
  final CounterRepository repository;

  CounterViewModel(this.repository);

  int getCount() => repository.getCount();
}
