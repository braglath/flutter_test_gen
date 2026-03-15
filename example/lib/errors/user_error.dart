sealed class UserError {
  const UserError();
}

class UserNotFound extends UserError {
  const UserNotFound();
}

class UserBlocked extends UserError {
  const UserBlocked();
}
