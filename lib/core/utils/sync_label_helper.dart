String getSyncLabel(String status) {
  switch (status) {
    case "synced":
      return "Synced";
    case "pending":
      return "Pending Sync";
    case "conflict":
      return "Conflict";
    case "failed":
      return "Failed";
    default:
      return "Unknown";
  }
}
