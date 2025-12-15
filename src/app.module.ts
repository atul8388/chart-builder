import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { UsersModule } from './users/users.module';
import { ProcessorModule } from './processor/processor.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    // TypeORM configuration - uncomment when database is ready
    // TypeOrmModule.forRootAsync({
    //   imports: [ConfigModule],
    //   useFactory: (configService: ConfigService) => ({
    //     type: configService.get<string>('DB_TYPE') as any,
    //     host: configService.get<string>('DB_HOST'),
    //     port: parseInt(configService.get<string>('DB_PORT') || '1433', 10),
    //     username: configService.get<string>('DB_USERNAME'),
    //     password: configService.get<string>('DB_PASSWORD'),
    //     database: configService.get<string>('DB_DATABASE'),
    //     entities: [__dirname + '/**/*.entity{.ts,.js}'],
    //     synchronize: true, // Set to false in production
    //     logging: true,
    //     retryAttempts: 3,
    //     retryDelay: 3000,
    //     autoLoadEntities: true,
    //     options: {
    //       encrypt: false, // Set to true if using Azure
    //       trustServerCertificate: true, // Set to false in production with valid certificates
    //     },
    //   }),
    //   inject: [ConfigService],
    // }),
    // UsersModule, // Uncomment when database is ready
    ProcessorModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
