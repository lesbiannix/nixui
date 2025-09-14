# Tailwind CSS class composition helpers
{
  # Compose a list of classes into a single string
  compose = classes: builtins.concatStringsSep " " classes;
}
