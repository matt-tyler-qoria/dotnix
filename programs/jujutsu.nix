{ userName, userEmail }:
{
  enable = true;
  settings = {
    user = {
      name = userName;
      email = userEmail;
    };
  };
}
