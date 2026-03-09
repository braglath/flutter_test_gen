class CounterRepository {
  int getCount() {
    return 1;
  }
}

class CounterViewModel {
  final CounterRepository repository;

  CounterViewModel(this.repository);

  int getCount() {
    return repository.getCount();
  }
}
