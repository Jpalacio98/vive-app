



String toCamelCase(String input) {
  return input
      .trim()
      .split(' ')
      .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
      .join('');
}