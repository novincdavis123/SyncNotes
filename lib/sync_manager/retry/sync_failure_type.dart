enum SyncFailureType {
  network, // No internet / connectivity issue
  server, // 5xx errors / backend failure
  timeout, // request took too long
  conflict, // data version mismatch
  validation, // invalid payload / bad data
  unknown, // fallback for unexpected errors
}
