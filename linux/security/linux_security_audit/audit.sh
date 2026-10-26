#!/bin/bash

PERMIT_ROOT_LOGIN=$(sshd -T | grep '^permitrootlogin' | awk '{print $2}')

if [ "$PERMIT_ROOT_LOGIN" = "no" ]; then
	echo "[PASS] SSH root login disabled"
elif [ "$PERMIT_ROOT_LOGIN" = "prohibit-password" ]; then
	echo "[WARNING] SSH root login allowed with key authentication"
else
	echo "[FAIL] SSH root login setting: $PERMIT_ROOT_LOGIN"
fi

PASSWORD_AUTHENTICATION=$(sshd -T | grep '^passwordauthentication' | awk '{print $2}')

if [ "$PASSWORD_AUTHENTICATION" = "no" ]; then
	echo "[PASS] SSH password authentication disabled"
else
	echo "[WARNING] SSH password authentication enabled"
fi

PUBKEY_AUTHENTICATION=$(sshd -T | grep '^pubkeyauthentication' | awk '{print $2}')

if [ "$PUBKEY_AUTHENTICATION" = "yes" ]; then
	echo "[PASS] SSH pubkey authentication enabled"
else
	echo "[WARNING] SSH pubkey authentication disabled"
fi

UID0_USERS=$(awk -F: '$3 == 0 {print $1}' /etc/passwd)

if [ "$UID0_USERS" = "root" ]; then
	echo "[PASS] Only root account found"
else
	echo "[FAIL] Multiple UID 0 accounts found: $UID0_USERS"
fi

PASSWD_PERMISSIONS=$(stat -c "%a" /etc/passwd)

if [ "$PASSWD_PERMISSIONS" = "644" ]; then
	echo "[PASS] Only root can modify"
else
	echo "[FAIL] /etc/passwd permissions are $PASSWD_PERMISSIONS (expected: 644)"
fi


SHADOW_PERMISSIONS=$(stat -c "%a" /etc/shadow)
SHADOW_OWNER=$(stat -c "%U" /etc/shadow)
SHADOW_GROUP=$(stat -c "%G" /etc/shadow)

if [ "$SHADOW_PERMISSIONS" = "640" ] && \
	[ "$SHADOW_OWNER" = "root" ] && \
	[ "$SHADOW_GROUP" = "shadow" ]; then
	
	echo "[PASS] /etc/shadow permissions and ownership are correct"
else
	echo "[FAIL] /etc/shadow => permissions=$SHADOW_PERMISSIONS, owner=$SHADOW_OWNER and group=$SHADOW_GROUP"
fi

EMPTY_PASSWORD_USERS=$(awk -F: '($2 == "") {print $1}' /etc/shadow)

if [ -z $EMPTY_PASSWORD_USERS ]; then
	echo "[PASS] No account has an empty password"
else
	echo "[FAIL] Accounts with an empty password: $EMPTY_PASSWORD_USERS"
fi

echo "[INFO] Listening TCP/UDP ports:"

LISTENING_PORTS=$(ss -tuln | awk 'NR>1 {print $5}' | sed 's/.*://' | sort -n | uniq)

if [ -z "$LISTENING_PORTS" ]; then
	echo "[INFO] No listening ports found"
else
	echo "$LISTENING_PORTS"
fi

UFW_STATUS=$(ufw status 2>/dev/null | head -n 1)

if echo "$UFW_STATUS" | grep -q "Status: active"; then
	echo "[PASS] UFW firewall is active"
else
	echo "[WARNING UFW firewall is not active"
fi

NFT_RULES=$(nft list ruleset 2>/dev/null)

if [ -n "$NFT_RULES" ]; then
	echo "[PASS] nftables rules detected"
else
	echo "[INFO] No nftables ruleset detected"
fi

UPGRADABLE_COUNT=$(apt list --upgradable 2>/dev/null | tail -n +2  | wc -l)

if [ "$UPGRADABLE_COUNT" -eq 0 ]; then
	echo "[PASS] System packages are up to date"
else
	echo "[WARNING] $UPGRADABLE_COUNT package(s) can be upgraded"
fi

SUDOERS_PERMISSIONS=$(stat -c "%a" /etc/sudoers)
SUDOERS_OWNER=$(stat -c "%U" /etc/sudoers)
SUDOERS_GROUP=$(stat -c "%G" /etc/sudoers)

if [ "$SUDOERS_PERMISSIONS" = "440" ] && \
	[ "$SUDOERS_OWNER" = "root" ] && \
	[ "$SUDOERS_GROUP" = "root" ]; then

	echo "[PASS] /etc/sudoers permissions and ownership are corrct"
else
	echo "[FAIL] /etc/sudoers => permissions=$SUDOERS_PERMISSIONS, owner=$SUDOERS_OWNER and group=$SUDOERS_GROUP"
fi

INTERACTIVE_USERS=$(awk -F: '$3 >= 1000 && $7 !~ /(nologin|false)$/ {print $1}' /etc/passwd)
echo "[INFO] Accounts with an interactive shell:"
echo "$INTERACTIVE_USERS"
