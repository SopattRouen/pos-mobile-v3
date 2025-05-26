enum RoleEnum {
  admin,
  operator,
  user,
  guest; // Added guest role for unauthenticated users

  String get displayName {
    switch (this) {
      case RoleEnum.admin:
        return 'អភិបាលប្រព័ន្ធ';
      case RoleEnum.operator:
        return 'ប្រតិបត្តីករ';
      case RoleEnum.user:
        return 'ប្រិយមិត្ត';
      case RoleEnum.guest:
        return 'ភ្ញៀវ';
    }
  }

  int get priority {
    switch (this) {
      case RoleEnum.admin:
        return 3;
      case RoleEnum.operator:
        return 2;
      case RoleEnum.user:
        return 1;
      case RoleEnum.guest:
        return 0;
    }
  }
}