<?php
require __DIR__ . '/db.php';
if ($_SERVER['REQUEST_METHOD'] !== 'POST') respond(405, ['error' => 'Method not allowed']);

try {
    $in = json_input();
    $name = trim($in['name'] ?? '');
    $email = strtolower(trim($in['email'] ?? ''));
    $password = $in['password'] ?? '';
    $confirm = $in['confirm_password'] ?? '';

    if ($name === '' || $email === '' || $password === '' || $confirm === '')
        respond(422, ['error' => 'All fields are required']);
    if (!filter_var($email, FILTER_VALIDATE_EMAIL))
        respond(422, ['error' => 'Invalid email format']);
    if (strlen($password) < 8)
        respond(422, ['error' => 'Password must be at least 8 characters']);
    if ($password !== $confirm)
        respond(422, ['error' => 'Passwords do not match']);

    $pdo = db();
    $st = $pdo->prepare('SELECT 1 FROM users WHERE email = ?');
    $st->execute([$email]);
    if ($st->fetch()) respond(409, ['error' => 'Email already registered']);

    // Role is ALWAYS 'player' here; the client cannot choose it.
    $st = $pdo->prepare('INSERT INTO users (name, email, password_hash, role, created_at)
                         VALUES (?, ?, ?, ?, ?)');
    $st->execute([$name, $email, password_hash($password, PASSWORD_DEFAULT), 'player', gmdate('Y-m-d H:i:s')]);

    respond(201, ['message' => 'Account created successfully']);
} catch (Throwable $e) {
    respond(500, ['error' => 'Server error']);
}