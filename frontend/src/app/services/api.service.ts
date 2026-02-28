import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

export interface HelloResponse {
    message: string;
    timestamp: string;
    status: string;
}

export interface Game {
    id: number;
    title: string;
    platform: string;
    genre: string;
    status: string;
    personalRating: number | null;
    coverUrl: string | null;
    createdAt: string;
    updatedAt: string;
}

@Injectable({
    providedIn: 'root',
})
export class ApiService {
    private baseUrl = environment.apiUrl;

    constructor(private http: HttpClient) {}

    getHello(): Observable<HelloResponse> {
        return this.http.get<HelloResponse>(`${this.baseUrl}/hello`);
    }

    getGames(): Observable<Game[]> {
        return this.http.get<Game[]>(`${this.baseUrl}/games`);
    }

    getGame(id: number): Observable<Game> {
        return this.http.get<Game>(`${this.baseUrl}/games/${id}`);
    }
}
