import path from 'path';
import dotenv from 'dotenv';
import express from 'express';
import cors from 'cors';
import bodyParser from 'body-parser';
import router from './routes/routes';
import { errorHandler } from './middleware/error_handler';

// .env dosyasının yolunu doğru şekilde belirt
dotenv.config({ path: path.join(__dirname, '../.env') });

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware'ler
app.use(cors());
app.use(bodyParser.json());

// API anahtarı kontrolü
if (!process.env.GEMINI_API_KEY) {
    console.error('UYARI: GEMINI_API_KEY bulunamadı!');
    process.exit(1);
}

// Routes
app.use('/api/v1', router);

// Error handler middleware
app.use((err: Error, req: express.Request, res: express.Response, next: express.NextFunction) => {
    errorHandler(err, req, res, next);
});

app.listen(PORT, () => {
    console.log(`Server is running on localhost:${PORT}`);
});