\echo Use "CREATE EXTENSION plschemeu" to load this file. \quit

CREATE FUNCTION plschemeu_call_handler() RETURNS language_handler
AS 'MODULE_PATHNAME','plschemeu_call_handler'
LANGUAGE C PARALLEL SAFE;

CREATE LANGUAGE plschemeu HANDLER plschemeu_call_handler;

