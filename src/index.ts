import { Elysia, file } from "elysia";

const app = new Elysia().get("/", "Hello World!").listen(3000);
