const { createProxyMiddleware } = require('http-proxy-middleware');

/**
 * Setup backend-fetch proxy for localhost:8080.
 */
module.exports = function (app) {
    app.use(
        '/api/',
        createProxyMiddleware({
            target: 'http://localhost:8080',
            changeOrigin: false,
            secure: false,
            // pathRewrite: {
            //     '^/php': '/public/php'
            // }
        })
    );
};