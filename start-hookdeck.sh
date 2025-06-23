#!/bin/sh

echo "🔐 Autenticando Hookdeck CLI..."
hookdeck ci --api-key $HOOKDECK_API_KEY

echo "🔁 Iniciando escucha de Hookdeck..."
hookdeck listen http://payments-service:3003/payments/webhook $HOOCKED_SOURCE payments-ms

chmod +x start-hookdeck.sh
