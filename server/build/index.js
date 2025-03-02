"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const path_1 = __importDefault(require("path"));
const dotenv_1 = __importDefault(require("dotenv"));
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const body_parser_1 = __importDefault(require("body-parser"));
const routes_1 = __importDefault(require("./routes/routes"));
const error_handler_1 = require("./middleware/error_handler");
// .env dosyasının yolunu doğru şekilde belirt
dotenv_1.default.config({ path: path_1.default.join(__dirname, '../.env') });
const app = (0, express_1.default)();
const PORT = process.env.PORT || 3000;
// Middleware'ler
app.use((0, cors_1.default)());
app.use(body_parser_1.default.json());
// API anahtarı kontrolü
if (!process.env.GEMINI_API_KEY) {
    console.error('UYARI: GEMINI_API_KEY bulunamadı!');
    process.exit(1);
}
// Routes
app.use('/api/v1', routes_1.default);
// Error handler middleware
app.use((err, req, res, next) => {
    (0, error_handler_1.errorHandler)(err, req, res, next);
});
app.listen(PORT, () => {
    console.log(`Server is running on localhost:${PORT}`);
});
