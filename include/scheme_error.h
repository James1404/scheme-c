#ifndef MERIDIAN_ERROR_H
#define MERIDIAN_ERROR_H

typedef enum {
    ErrorSeverity_Info,
    ErrorSeverity_Warning,
    ErrorSeverity_Error,
} ErrorSeverity;

typedef void (*ErrorCallback)(const char* msg, ErrorSeverity severity);
void Scheme_set_error_callback(ErrorCallback fn);

void Scheme_error(const char* msg);

#endif//MERIDIAN_ERROR_H
