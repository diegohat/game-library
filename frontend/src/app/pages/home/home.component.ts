import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ApiService, Game, HelloResponse } from '../../services/api.service';

@Component({
    selector: 'app-home',
    standalone: true,
    imports: [CommonModule],
    template: `
        <main class="container">
            <header class="hero">
                <h1>🎮 Game Library Tracker</h1>
                @if (hello) {
                    <p class="status">
                        API Status: <strong>{{ hello.status }}</strong> &mdash;
                        {{ hello.message }}
                    </p>
                } @else if (error) {
                    <p class="status error">⚠️ API offline — start the backend with <code>make run-api</code></p>
                } @else {
                    <p class="status loading">Connecting to API...</p>
                }
            </header>

            <section class="games">
                <h2>My Games</h2>
                @if (games.length > 0) {
                    <div class="game-grid">
                        @for (game of games; track game.id) {
                            <article class="game-card">
                                <h3>{{ game.title }}</h3>
                                <div class="meta">
                                    <span class="badge platform">{{ game.platform }}</span>
                                    @if (game.genre) {
                                        <span class="badge genre">{{ game.genre }}</span>
                                    }
                                    <span class="badge status" [attr.data-status]="game.status">{{ game.status }}</span>
                                </div>
                                @if (game.personalRating !== null && game.personalRating > 0) {
                                    <p class="rating">⭐ {{ game.personalRating }}/10</p>
                                }
                            </article>
                        }
                    </div>
                } @else if (!error) {
                    <p class="empty">
                        No games found. Seed data will appear after running with the <code>dev</code> profile.
                    </p>
                }
            </section>
        </main>
    `,
    styles: [
        `
            .container {
                max-width: 960px;
                margin: 0 auto;
                padding: 2rem 1rem;
                font-family:
                    'Segoe UI',
                    system-ui,
                    -apple-system,
                    sans-serif;
            }

            .hero {
                text-align: center;
                margin-bottom: 2rem;
            }

            .hero h1 {
                font-size: 2rem;
                margin-bottom: 0.5rem;
            }

            .status {
                color: #4caf50;
                font-size: 0.95rem;
            }

            .status.error {
                color: #f44336;
            }

            .status.loading {
                color: #ff9800;
            }

            code {
                background: #f5f5f5;
                padding: 0.15em 0.4em;
                border-radius: 4px;
                font-size: 0.9em;
            }

            .games h2 {
                border-bottom: 2px solid #e0e0e0;
                padding-bottom: 0.5rem;
                margin-bottom: 1rem;
            }

            .game-grid {
                display: grid;
                grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
                gap: 1rem;
            }

            .game-card {
                border: 1px solid #e0e0e0;
                border-radius: 8px;
                padding: 1rem;
                transition: box-shadow 0.2s;
            }

            .game-card:hover {
                box-shadow: 0 2px 8px rgba(0, 0, 0, 0.12);
            }

            .game-card h3 {
                margin: 0 0 0.5rem;
                font-size: 1.1rem;
            }

            .meta {
                display: flex;
                gap: 0.4rem;
                flex-wrap: wrap;
                margin-bottom: 0.5rem;
            }

            .badge {
                font-size: 0.75rem;
                padding: 0.2em 0.6em;
                border-radius: 12px;
                font-weight: 600;
            }

            .badge.platform {
                background: #e3f2fd;
                color: #1565c0;
            }

            .badge.genre {
                background: #f3e5f5;
                color: #7b1fa2;
            }

            .badge.status {
                background: #fff3e0;
                color: #e65100;
            }

            .badge.status[data-status='COMPLETED'] {
                background: #e8f5e9;
                color: #2e7d32;
            }

            .badge.status[data-status='PLAYING'] {
                background: #e3f2fd;
                color: #1565c0;
            }

            .badge.status[data-status='ABANDONED'] {
                background: #fce4ec;
                color: #c62828;
            }

            .rating {
                margin: 0;
                font-size: 0.9rem;
                color: #555;
            }

            .empty {
                color: #999;
                text-align: center;
                padding: 2rem;
            }
        `,
    ],
})
export class HomeComponent implements OnInit {
    hello: HelloResponse | null = null;
    games: Game[] = [];
    error = false;

    constructor(private apiService: ApiService) {}

    ngOnInit(): void {
        this.apiService.getHello().subscribe({
            next: (response) => (this.hello = response),
            error: () => (this.error = true),
        });

        this.apiService.getGames().subscribe({
            next: (games) => (this.games = games),
            error: () => {},
        });
    }
}
