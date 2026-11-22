<?php
require __DIR__ . '/db.php';
if ($_SERVER['REQUEST_METHOD'] !== 'POST') respond(405, ['error' => 'Method not allowed']);

try {
    $in = json_input();
    $email = strtolower(trim($in['email'] ?? ''));
    $password = $in['password'] ?? '';
    if ($email === '' || $password === '') respond(422, ['error' => 'Email and password are required']);

    $pdo = db();
    $st = $pdo->prepare('SELECT id, password_hash FROM users WHERE email = ?');
    $st->execute([$email]);
    $user = $st->fetch();

    if (!$user || !password_verify($password, $user['password_hash']))
        respond(401, ['error' => 'Invalid email or password']);

    $token = bin2hex(random_bytes(32));
    $st = $pdo->prepare('INSERT INTO sessions (user_id, token_hash, expires_at, created_at) VALUES (?, ?, ?, ?)');
    $st->execute([
        $user['id'],
        hash('sha256', $token),
        gmdate('Y-m-d H:i:s', time() + 7 * 24 * 3600),
        gmdate('Y-m-d H:i:s'),
    ]);

    respond(200, ['message' => 'Login successful', 'token' => $token]);
} catch (Throwable $e) {
    respond(500, ['error' => 'Server error']);
}