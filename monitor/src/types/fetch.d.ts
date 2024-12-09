import { RequestInit } from 'node-fetch';

declare module 'node-fetch' {
  export interface RequestInit {
    timeout?: number;
  }
}
