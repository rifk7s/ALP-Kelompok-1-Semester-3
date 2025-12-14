<?php

namespace App\Providers;

use Dedoc\Scramble\Scramble;
use Dedoc\Scramble\Support\Generator\OpenApi;
use Dedoc\Scramble\Support\Generator\Operation;
use Dedoc\Scramble\Support\Generator\SecurityRequirement;
use Dedoc\Scramble\Support\Generator\SecurityScheme;
use Dedoc\Scramble\Support\RouteInfo;
use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Str;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        // Allow viewing docs in local/dev by default.
        Gate::define('viewApiDocs', fn () => app()->environment(['local', 'development']));

        // Scramble: add Bearer auth scheme and apply it only to routes protected by `auth:*` middleware.
        Scramble::configure()
            ->withDocumentTransformers(function (OpenApi $openApi) {
                $openApi->components->addSecurityScheme(
                    'bearerAuth',
                    SecurityScheme::http('bearer')
                        ->as('bearerAuth')
                        ->setDescription('Use `Authorization: Bearer <token>` obtained from `POST /api/auth/login`.')
                );
            })
            ->withOperationTransformers(function (Operation $operation, RouteInfo $routeInfo) {
                $routeMiddleware = $routeInfo->route->gatherMiddleware();

                $hasAuthMiddleware = collect($routeMiddleware)->contains(function ($middleware) {
                    return is_string($middleware)
                        && ($middleware === 'auth' || Str::startsWith($middleware, 'auth:'));
                });

                if ($hasAuthMiddleware) {
                    $operation->security = [new SecurityRequirement('bearerAuth')];
                }
            });
    }
}
