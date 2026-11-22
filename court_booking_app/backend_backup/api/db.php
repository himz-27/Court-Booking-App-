<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
if (($_SERVER['REQUEST_METHOD'] ?? '') === 'OPTIONS') { http_response_code(204); exit; }

function respond($code, $data) {
    http_response_code($code);
    echo json_encode($data);
    exit;
}

function db() {
    // Database file lives in this same folder; .htaccess blocks direct download.
    $pdo = new PDO('sqlite:' . __DIR__ . '/court.db');
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
    $pdo->exec('PRAGMA foreign_keys = ON');
    $pdo->exec("CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'player',
        created_at TEXT NOT NULL
    )");
    $pdo->exec("CREATE TABLE IF NOT EXISTS sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        token_hash TEXT NOT NULL UNIQUE,
        expires_at TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    )");

    // Controlled setup: the second role (court_admin) is created here by the
    // backend, never through public registration. Runs once; skipped if it exists.
    $st = $pdo->prepare('SELECT 1 FROM users WHERE email = ?');
    $st->execute(['admin@courtbook.test']);
    if (!$st->fetch()) {
        $st = $pdo->prepare('INSERT OR IGNORE INTO users (name, email, password_hash, role, created_at) VALUES (?, ?, ?, ?, ?)');
        $st->execute(['Court Admin', 'admin@courtbook.test', password_hash('Admin12345', PASSWORD_DEFAULT), 'court_admin', gmdate('Y-m-d H:i:s')]);
    }
    return $pdo;
}

function json_input() {
    $d = json_decode(file_get_contents('php://input'), true);
    return is_array($d) ? $d : [];
}

function bearer_token() {
    $h = $_SERVER['HTTP_AUTHORIZATION'] ?? $_SERVER['REDIRECT_HTTP_AUTHORIZATION'] ?? '';
    if (!$h && function_exists('getallheaders')) {
        foreach (getallheaders() as $k => $v) {
            if (strtolower($k) === 'authorization') $h = $v;
        }
    }
    return preg_match('/^Bearer\s+(\S+)$/i', $h, $m) ? $m[1] : null;
}

function current_user($pdo) {
    $t = bearer_token();
    if (!$t) return null;
    $st = $pdo->prepare("SELECT u.id, u.name, u.email, u.role
        FROM sessions s JOIN users u ON u.id = s.user_id
        WHERE s.token_hash = ? AND s.expires_at > ?");
    $st->execute([hash('sha256', $t), gmdate('Y-m-d H:i:s')]);
    return $st->fetch() ?: null;
}